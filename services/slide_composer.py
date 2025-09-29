"""
Slide composer skeleton:
- given an outline and chart image paths, compose a PPTX using python-pptx
- requires `pip install python-pptx pillow`
"""
from pptx import Presentation
from pptx.util import Inches, Pt
from pathlib import Path

def create_pptx(outline: dict, chart_image_map: dict, output_path: str):
    prs = Presentation()
    # Use a simple title slide if present
    for slide_info in outline.get("slides", []):
        slide_layout = prs.slide_layouts[5]  # blank-like layout
        slide = prs.slides.add_slide(slide_layout)
        left = Inches(0.5)
        top = Inches(0.3)
        width = Inches(9)
        # Title
        title_box = slide.shapes.add_textbox(left, top, width, Inches(0.6))
        tf = title_box.text_frame
        tf.text = slide_info.get("title", "")
        # Bullets
        top = Inches(1.0)
        tb = slide.shapes.add_textbox(left, top, width, Inches(1.6))
        tf = tb.text_frame
        for b in slide_info.get("bullets", []):
            p = tf.add_paragraph()
            p.text = b
            p.level = 0
            p.font.size = Pt(14)
        # Chart image if exists
        chart_ids = slide_info.get("chart_ids", [])
        if chart_ids:
            img_path = chart_image_map.get(chart_ids[0])
            if img_path and Path(img_path).exists():
                slide.shapes.add_picture(img_path, Inches(6.5), Inches(1.0), height=Inches(3.5))
        # Speaker notes
        notes = slide.notes_slide.notes_text_frame
        notes.text = slide_info.get("notes", "")
    prs.save(output_path)
    return output_path