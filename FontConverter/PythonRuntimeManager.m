#import "PythonRuntimeManager.h"
#import <Python/Python.h>

@implementation PythonRuntimeManager

+ (instancetype)shared {
    static PythonRuntimeManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [PythonRuntimeManager new]; });
    return instance;
}

- (BOOL)start:(NSError **)error {
    static BOOL started = NO;
    static dispatch_once_t onceToken;
    __block NSError *startupError = nil;

    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *pythonHome = [bundle pathForResource:@"PythonHome" ofType:nil];
        NSString *pythonApp = [bundle pathForResource:@"PythonApp" ofType:nil];
        if (!pythonHome || !pythonApp) {
            startupError = [NSError errorWithDomain:@"FontConverter.Python"
                                                code:1
                                            userInfo:@{NSLocalizedDescriptionKey:
                                                       @"PythonHome/PythonApp not found in the app bundle."}];
            return;
        }

        setenv("PYTHONHOME", pythonHome.UTF8String, 1);
        setenv("PYTHONPATH", pythonApp.UTF8String, 1);
        setenv("PYTHONNOUSERSITE", "1", 1);
        setenv("PYTHONUNBUFFERED", "1", 1);

        PyStatus status;
        PyPreConfig preconfig;
        PyPreConfig_InitIsolatedConfig(&preconfig);
        preconfig.utf8_mode = 1;
        status = Py_PreInitialize(&preconfig);
        if (PyStatus_Exception(status)) {
            startupError = [NSError errorWithDomain:@"FontConverter.Python" code:2
                                             userInfo:@{NSLocalizedDescriptionKey:
                                                        [NSString stringWithUTF8String:PyStatus_IsExit(status) ? "Python requested exit" : status.err_msg ?: "Py_PreInitialize failed"]}];
            return;
        }

        PyConfig config;
        PyConfig_InitIsolatedConfig(&config);
        status = PyConfig_SetBytesString(&config, &config.home, pythonHome.UTF8String);
        if (PyStatus_Exception(status)) { PyConfig_Clear(&config); startupError = [NSError errorWithDomain:@"FontConverter.Python" code:3 userInfo:@{NSLocalizedDescriptionKey:@"Failed to configure PYTHONHOME."}]; return; }
        status = PyConfig_SetBytesString(&config, &config.program_name, "FontConverter");
        if (PyStatus_Exception(status)) { PyConfig_Clear(&config); startupError = [NSError errorWithDomain:@"FontConverter.Python" code:4 userInfo:@{NSLocalizedDescriptionKey:@"Failed to configure program name."}]; return; }
        wchar_t *pythonAppWide = Py_DecodeLocale(pythonApp.UTF8String, NULL);
        if (!pythonAppWide) {
            PyConfig_Clear(&config);
            startupError = [NSError errorWithDomain:@"FontConverter.Python" code:4
                                             userInfo:@{NSLocalizedDescriptionKey:@"Failed to encode PythonApp path."}];
            return;
        }
        status = PyWideStringList_Append(&config.module_search_paths, pythonAppWide);
        PyMem_RawFree(pythonAppWide);
        if (PyStatus_Exception(status)) {
            PyConfig_Clear(&config);
            startupError = [NSError errorWithDomain:@"FontConverter.Python" code:4
                                             userInfo:@{NSLocalizedDescriptionKey:@"Failed to configure Python module search path."}];
            return;
        }
        status = Py_InitializeFromConfig(&config);
        PyConfig_Clear(&config);
        if (PyStatus_Exception(status)) {
            startupError = [NSError errorWithDomain:@"FontConverter.Python" code:5
                                             userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithUTF8String:status.err_msg ?: "Py_InitializeFromConfig failed"]}];
            return;
        }
        started = YES;
    });

    if (error) *error = startupError;
    return started && startupError == nil;
}
@end
