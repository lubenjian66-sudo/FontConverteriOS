from __future__ import annotations

import os
from fontTools.ttLib import TTFont, TTCollection
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.pens.transformPen import TransformPen
from fontTools.misc.transform import Scale


def _ascii_glyph_names(source_font):
    names = set()
    for table in source_font['cmap'].tables:
        for codepoint, glyph_name in table.cmap.items():
            if 0x20 <= codepoint <= 0x7E:
                names.add(glyph_name)
    return list(names)


def _scale_ratio(source_font, target_font):
    src_upem = source_font['head'].unitsPerEm
    if isinstance(target_font, TTCollection):
        tgt_upem = target_font.fonts[0]['head'].unitsPerEm
    else:
        tgt_upem = target_font['head'].unitsPerEm
    return tgt_upem / src_upem


def _inject_glyphs(source_font, target_font, glyph_names, final_scale):
    source_glyph_set = source_font.getGlyphSet()
    target_fonts = target_font.fonts if isinstance(target_font, TTCollection) else [target_font]
    matrix = Scale(final_scale)

    for t_font in target_fonts:
        glyf_table = t_font['glyf']
        hmtx_table = t_font['hmtx']

        for glyph_name in glyph_names:
            if glyph_name not in source_glyph_set or glyph_name not in glyf_table:
                continue
            new_pen = TTGlyphPen(None)
            transformer = TransformPen(new_pen, matrix)
            source_glyph_set[glyph_name].draw(transformer)
            glyf_table[glyph_name] = new_pen.glyph()

            if glyph_name in source_font['hmtx'].metrics:
                width, lsb = source_font['hmtx'].metrics[glyph_name]
                hmtx_table.metrics[glyph_name] = (
                    int(width * final_scale),
                    int(lsb * final_scale),
                )

            if 'gvar' in t_font and glyph_name in t_font['gvar'].variations:
                del t_font['gvar'].variations[glyph_name]

        if 'HVAR' in t_font:
            del t_font['HVAR']
        t_font.recalcBBoxes = True


def convert_font(source_path: str, template_path: str, output_path: str,
                 is_ttc_mode: bool, manual_scale: float = 1.0) -> str:
    """Convert one font using the original project's algorithm."""
    source_path = os.path.abspath(source_path)
    template_path = os.path.abspath(template_path)
    output_path = os.path.abspath(output_path)

    if not os.path.isfile(source_path):
        raise FileNotFoundError(f"Source font not found: {source_path}")
    if not os.path.isfile(template_path):
        raise FileNotFoundError(f"Template font not found: {template_path}")
    if manual_scale <= 0:
        raise ValueError("manual_scale must be greater than 0")

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    source_font = TTFont(source_path, fontNumber=0)
    target_obj = TTCollection(template_path) if is_ttc_mode else TTFont(template_path)

    try:
        auto_ratio = _scale_ratio(source_font, target_obj)
        final_scale = auto_ratio * float(manual_scale)
        glyph_names = _ascii_glyph_names(source_font)
        _inject_glyphs(source_font, target_obj, glyph_names, final_scale)
        target_obj.save(output_path)
    finally:
        source_font.close()
        target_obj.close()

    return output_path
