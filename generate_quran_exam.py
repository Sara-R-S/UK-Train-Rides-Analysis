#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.units import cm
import arabic_reshaper
from bidi.algorithm import get_display

def reshape_arabic(text):
    """تنسيق النص العربي للعرض بشكل صحيح"""
    reshaped_text = arabic_reshaper.reshape(text)
    return get_display(reshaped_text)

def create_quran_exam_pdf():
    # إنشاء ملف PDF
    pdf_file = "امتحان_قرآن_الصف_الخامس_الابتدائي.pdf"
    c = canvas.Canvas(pdf_file, pagesize=A4)
    width, height = A4

    # محاولة استخدام خط عربي (إذا كان متاحاً)
    try:
        # تسجيل خط عربي
        pdfmetrics.registerFont(TTFont('Arabic', '/usr/share/fonts/dejavu/DejaVuSans.ttf'))
        arabic_font = 'Arabic'
    except:
        # استخدام خط افتراضي
        arabic_font = 'Helvetica'

    # إعدادات الصفحة
    margin = 2 * cm
    y_position = height - margin

    # العنوان الرئيسي
    c.setFont(arabic_font, 16)
    title1 = reshape_arabic("الأزهر الشريف معهد طلخا النموذجي")
    c.drawCentredString(width / 2, y_position, title1)
    y_position -= 1 * cm

    c.setFont(arabic_font, 14)
    title2 = reshape_arabic("امتحان القرآن الكريم للصف الخامس الابتدائي")
    c.drawCentredString(width / 2, y_position, title2)
    y_position -= 0.8 * cm

    c.setFont(arabic_font, 12)
    title3 = reshape_arabic("اختبار شهر أكتوبر ونوفمبر")
    c.drawCentredString(width / 2, y_position, title3)
    y_position -= 1.5 * cm

    # رسم خط فاصل
    c.line(margin, y_position, width - margin, y_position)
    y_position -= 1 * cm

    # السؤال الأول
    c.setFont(arabic_font, 13)
    q1_title = reshape_arabic("السؤال الأول:")
    c.drawRightString(width - margin, y_position, q1_title)
    y_position -= 0.8 * cm

    c.setFont(arabic_font, 11)
    q1_a = reshape_arabic("أ- أكتب من قوله تعالى:")
    c.drawRightString(width - margin, y_position, q1_a)
    y_position -= 0.7 * cm

    q1_a1 = reshape_arabic("قَالَ أَفَرَأَيْتُم مَّا كُنتُمْ تَعْبُدُونَ ....")
    c.drawRightString(width - margin - 0.5 * cm, y_position, q1_a1)
    y_position -= 0.7 * cm

    q1_a2 = reshape_arabic("إلى قوله تعالى:")
    c.drawRightString(width - margin, y_position, q1_a2)
    y_position -= 0.7 * cm

    q1_a3 = reshape_arabic("وَالَّذِي يُمِيتُنِي ثُمَّ يُحْيِينِ")
    c.drawRightString(width - margin - 0.5 * cm, y_position, q1_a3)
    y_position -= 1 * cm

    q1_b = reshape_arabic("ب- أكتب من أول سورة النمل إلى قوله تعالى:")
    c.drawRightString(width - margin, y_position, q1_b)
    y_position -= 0.7 * cm

    q1_b1 = reshape_arabic("وَهُم فِي الْآخِرَةِ هُمُ الْأَخْسَرُونَ")
    c.drawRightString(width - margin - 0.5 * cm, y_position, q1_b1)
    y_position -= 1.2 * cm

    # رسم خط فاصل
    c.line(margin, y_position, width - margin, y_position)
    y_position -= 1 * cm

    # السؤال الثاني
    c.setFont(arabic_font, 13)
    q2_title = reshape_arabic("السؤال الثاني:")
    c.drawRightString(width - margin, y_position, q2_title)
    y_position -= 0.8 * cm

    c.setFont(arabic_font, 11)
    q2_intro = reshape_arabic("أكمل كل آية مما يأتي ثم اذكر آية بعدها مع ذكر اسم السورة:")
    c.drawRightString(width - margin, y_position, q2_intro)
    y_position -= 0.9 * cm

    q2_a = reshape_arabic("أ- قال تعالى:")
    c.drawRightString(width - margin, y_position, q2_a)
    y_position -= 0.7 * cm

    q2_a1 = reshape_arabic("وَنُرِيدُ أَن نَّمُنَّ عَلَى الَّذِينَ اسْتُضْعِفُوا فِي الْأَرْضِ .....")
    c.drawRightString(width - margin - 0.5 * cm, y_position, q2_a1)
    y_position -= 0.9 * cm

    q2_b = reshape_arabic("ب- قال تعالى:")
    c.drawRightString(width - margin, y_position, q2_b)
    y_position -= 0.7 * cm

    q2_b1 = reshape_arabic("إِلَّا الَّذِي فَطَرَنِي .....")
    c.drawRightString(width - margin - 0.5 * cm, y_position, q2_b1)
    y_position -= 0.9 * cm

    q2_c = reshape_arabic("ج- قال تعالى:")
    c.drawRightString(width - margin, y_position, q2_c)
    y_position -= 0.7 * cm

    q2_c1 = reshape_arabic("وَاصْبِرْ لِحُكْمِ رَبِّكَ فَإِنَّكَ بِأَعْيُنِنَا .....")
    c.drawRightString(width - margin - 0.5 * cm, y_position, q2_c1)
    y_position -= 1.2 * cm

    # رسم خط فاصل
    c.line(margin, y_position, width - margin, y_position)
    y_position -= 1 * cm

    # السؤال الثالث
    c.setFont(arabic_font, 13)
    q3_title = reshape_arabic("السؤال الثالث:")
    c.drawRightString(width - margin, y_position, q3_title)
    y_position -= 0.8 * cm

    c.setFont(arabic_font, 11)
    q3_intro = reshape_arabic("اكتب آيتين من أوائل السور الآتية:")
    c.drawRightString(width - margin, y_position, q3_intro)
    y_position -= 0.9 * cm

    q3_a = reshape_arabic("أ- الجاثية")
    c.drawRightString(width - margin, y_position, q3_a)
    y_position -= 0.9 * cm

    q3_b = reshape_arabic("ب- الصف")
    c.drawRightString(width - margin, y_position, q3_b)
    y_position -= 0.9 * cm

    q3_c = reshape_arabic("ج- المزمل")
    c.drawRightString(width - margin, y_position, q3_c)
    y_position -= 1.5 * cm

    # رسم خط فاصل في الأسفل
    c.line(margin, y_position, width - margin, y_position)
    y_position -= 0.8 * cm

    # تذييل
    c.setFont(arabic_font, 10)
    footer = reshape_arabic("بالتوفيق والنجاح")
    c.drawCentredString(width / 2, y_position, footer)

    # حفظ الملف
    c.save()
    print(f"تم إنشاء ملف PDF بنجاح: {pdf_file}")
    return pdf_file

if __name__ == "__main__":
    create_quran_exam_pdf()
