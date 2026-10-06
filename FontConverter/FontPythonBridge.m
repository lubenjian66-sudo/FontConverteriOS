#import "FontPythonBridge.h"
#import "PythonRuntimeManager.h"
#import <Python/Python.h>

static NSString *PyErrorString(void) {
    if (!PyErr_Occurred()) return @"Unknown Python error";
    PyObject *type = NULL, *value = NULL, *traceback = NULL;
    PyErr_Fetch(&type, &value, &traceback);
    PyErr_NormalizeException(&type, &value, &traceback);
    PyObject *str = value ? PyObject_Str(value) : NULL;
    const char *utf8 = str ? PyUnicode_AsUTF8(str) : NULL;
    NSString *result = utf8 ? [NSString stringWithUTF8String:utf8] : @"Python exception";
    Py_XDECREF(str); Py_XDECREF(type); Py_XDECREF(value); Py_XDECREF(traceback);
    return result;
}

@implementation FontPythonBridge

+ (void)convertSource:(NSString *)sourcePath
          templatePath:(NSString *)templatePath
            outputPath:(NSString *)outputPath
               ttcMode:(BOOL)ttcMode
          manualScale:(double)manualScale
            completion:(void (^)(BOOL, NSString * _Nullable))completion {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSError *startupError = nil;
        if (![[PythonRuntimeManager shared] start:&startupError]) {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, startupError.localizedDescription); });
            return;
        }

        PyGILState_STATE gil = PyGILState_Ensure();
        BOOL ok = NO;
        NSString *message = nil;
        PyObject *module = PyImport_ImportModule("font_converter_ios");
        if (!module) {
            message = PyErrorString();
        } else {
            PyObject *fn = PyObject_GetAttrString(module, "convert_font");
            if (!fn || !PyCallable_Check(fn)) {
                message = @"font_converter_ios.convert_font is unavailable";
            } else {
                PyObject *args = Py_BuildValue("ssspd", sourcePath.UTF8String, templatePath.UTF8String, outputPath.UTF8String, ttcMode ? 1 : 0, manualScale);
                PyObject *result = PyObject_CallObject(fn, args);
                Py_DECREF(args);
                if (!result) {
                    message = PyErrorString();
                } else {
                    ok = YES;
                    Py_DECREF(result);
                }
            }
            Py_XDECREF(fn);
            Py_DECREF(module);
        }
        PyGILState_Release(gil);

        dispatch_async(dispatch_get_main_queue(), ^{ completion(ok, message); });
    });
}
@end
