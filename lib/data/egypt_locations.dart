/// Egyptian Governorates, Cities, and Districts Data Structure
/// This file contains the complete hierarchical location data for Egypt
library;

class District {
  final String name;

  const District(this.name);
}

class City {
  final String name;
  final List<District> districts;

  const City(this.name, this.districts);
}

class Governorate {
  final String name;
  final List<City> cities;

  const Governorate(this.name, this.cities);
}

/// Complete list of Egyptian governorates with their cities and districts
const List<Governorate> egyptianLocations = [
  // محافظة القاهرة
  Governorate('القاهرة', [
    City('القاهرة', [
      District('مدينة نصر'),
      District('مصر الجديدة'),
      District('وسط البلد'),
      District('الأزبكية'),
      District('الموسكي'),
      District('عين شمس'),
    ]),
  ]),

  // محافظة الجيزة
  Governorate('الجيزة', [
    City('الجيزة', [
      District('الدقي'),
      District('المهندسين'),
      District('العجوزة'),
      District('إمبابة'),
      District('بولاق الدكرور'),
    ]),
    City('6 أكتوبر', []),
    City('الشيخ زايد', []),
    City('حدائق أكتوبر', []),
    City('الحوامدية', []),
  ]),

  // محافظة الإسكندرية
  Governorate('الإسكندرية', [
    City('الإسكندرية', [
      District('محطة الرمل'),
      District('الإبراهيمية'),
      District('محرم بك'),
      District('كفر عبده'),
      District('سيدي بشر'),
      District('سموحة'),
      District('ميامي'),
      District('المنتزه'),
    ]),
    City('برج العرب', []),
    City('برج العرب الجديدة', []),
  ]),

  // محافظة القليوبية
  Governorate('القليوبية', [
    City('بنها', [District('وسط بنها')]),
    City('شبرا الخيمة', [District('وسط شبرا الخيمة')]),
    City('قليوب', []),
    City('القناطر الخيرية', []),
    City('الخانكة', []),
    City('كفر شكر', []),
    City('طوخ', []),
    City('شبين القناطر', []),
    City('العبور', []),
  ]),

  // محافظة الدقهلية
  Governorate('الدقهلية', [
    City('المنصورة', [District('وسط المنصورة')]),
    City('ميت غمر', []),
    City('طلخا', []),
    City('أجا', []),
    City('منية النصر', []),
    City('بني عبيد', []),
    City('السنبلاوين', []),
    City('شربين', []),
    City('دكرنس', []),
    City('المطرية', []),
    City('بلقاس', []),
    City('تمى الأمديد', []),
  ]),

  // محافظة الشرقية
  Governorate('الشرقية', [
    City('الزقازيق', [District('وسط الزقازيق')]),
    City('العاشر من رمضان', []),
    City('بلبيس', []),
    City('أبو كبير', []),
    City('فاقوس', []),
    City('منيا القمح', []),
    City('الحسينية', []),
    City('كفر صقر', []),
  ]),

  // محافظة الغربية
  Governorate('الغربية', [
    City('طنطا', [District('وسط طنطا')]),
    City('المحلة الكبرى', [District('وسط المحلة الكبرى')]),
    City('كفر الزيات', []),
    City('زفتى', []),
    City('السنطة', []),
    City('بسيون', []),
    City('قطور', []),
  ]),

  // محافظة المنوفية
  Governorate('المنوفية', [
    City('شبين الكوم', [District('وسط شبين الكوم')]),
    City('السادات', [District('وسط السادات')]),
    City('منوف', []),
    City('قويسنا', []),
    City('الباجور', []),
    City('أشمون', []),
    City('تلا', []),
    City('بركة السبع', []),
  ]),

  // محافظة كفر الشيخ
  Governorate('كفر الشيخ', [
    City('كفر الشيخ', [District('وسط كفر الشيخ')]),
    City('دسوق', [District('وسط دسوق')]),
    City('بلطيم', []),
    City('فوه', []),
    City('مطوبس', []),
    City('الحامول', []),
    City('سيدي سالم', []),
    City('الرياض', []),
    City('بيلا', []),
    City('قلين', []),
  ]),

  // محافظة البحيرة
  Governorate('البحيرة', [
    City('دمنهور', [District('وسط دمنهور')]),
    City('كفر الدوار', [District('وسط كفر الدوار')]),
    City('رشيد', []),
    City('إدكو', []),
    City('أبو حمص', []),
    City('أبو المطامير', []),
    City('الدلنجات', []),
    City('وادي النطرون', []),
    City('المحمودية', []),
  ]),

  // محافظة دمياط
  Governorate('دمياط', [
    City('دمياط', [District('وسط دمياط')]),
    City('دمياط الجديدة', [District('وسط دمياط الجديدة')]),
    City('رأس البر', []),
    City('فارسكور', []),
    City('الزرقا', []),
    City('كفر سعد', []),
    City('كفر البطيخ', []),
  ]),

  // محافظة بورسعيد
  Governorate('بورسعيد', [
    City('بورسعيد', [
      District('حي الشرق'),
      District('حي العرب'),
      District('حي الضواحي'),
      District('حي الزهور'),
      District('حي المناخ'),
      District('حي الجنوب'),
      District('حي الغرب'),
    ]),
    City('بورفؤاد', []),
  ]),

  // محافظة الإسماعيلية
  Governorate('الإسماعيلية', [
    City('الإسماعيلية', [
      District('وسط الإسماعيلية'),
      District('المناطق الصناعية والسياحية'),
    ]),
    City('فايد', []),
    City('التل الكبير', []),
    City('القنطرة شرق', []),
    City('القنطرة غرب', []),
    City('أبو صوير', []),
    City('القصاصين', []),
  ]),

  // محافظة السويس
  Governorate('السويس', [
    City('السويس', [
      District('حي الأربعين'),
      District('حي الجناين'),
      District('حي فيصل'),
      District('حي السويس'),
    ]),
  ]),

  // محافظة الفيوم
  Governorate('الفيوم', [
    City('الفيوم', [
      District('وسط الفيوم'),
      District('بحيرة قارون والمناطق القريبة'),
    ]),
  ]),

  // محافظة بني سويف
  Governorate('بني سويف', [
    City('بني سويف', [District('وسط بني سويف'), District('المنطقة الصناعية')]),
    City('بني سويف الجديدة', []),
    City('إهناسيا', []),
    City('الواسطي', []),
    City('ببا', []),
    City('سمسطا', []),
    City('ناصر', []),
  ]),

  // محافظة المنيا
  Governorate('المنيا', [
    City('المنيا', [District('وسط المنيا')]),
    City('المنيا الجديدة', []),
    City('ملوي', [District('وسط ملوي')]),
    City('سمالوط', []),
    City('بني مزار', []),
    City('مغاغة', []),
    City('مطاي', []),
  ]),

  // محافظة أسيوط
  Governorate('أسيوط', [
    City('أسيوط', [District('وسط أسيوط')]),
    City('أسيوط الجديدة', []),
    City('ديروط', [District('وسط ديروط')]),
    City('منفلوط', []),
    City('القوصية', []),
    City('أبوتيج', []),
    City('صدفا', []),
    City('الغنايم', []),
    City('ساحل سليم', []),
    City('الفتح', []),
    City('البداري', []),
  ]),

  // محافظة سوهاج
  Governorate('سوهاج', [
    City('سوهاج', [District('وسط سوهاج')]),
    City('سوهاج الجديدة', []),
    City('طهطا', []),
    City('جرجا', []),
    City('أخميم', []),
    City('المراغة', []),
    City('البلينا', []),
    City('دار السلام', []),
    City('جهينة', []),
    City('ساقلتة', []),
    City('العسيرات', []),
  ]),

  // محافظة قنا
  Governorate('قنا', [
    City('قنا', [District('وسط قنا')]),
    City('قنا الجديدة', []),
    City('نجع حمادي', []),
    City('قوص', []),
    City('دشنا', []),
    City('أبو تشت', []),
    City('نقادة', []),
    City('الوقف', []),
    City('فرشوط', []),
  ]),

  // محافظة الأقصر
  Governorate('الأقصر', [
    City('الأقصر', [District('وسط الأقصر'), District('طريق الكباش')]),
    City('إسنا', []),
    City('أرمنت', []),
    City('الطود', []),
    City('الزينية', []),
    City('القرنة', []),
  ]),

  // محافظة أسوان
  Governorate('أسوان', [
    City('أسوان', [District('وسط أسوان'), District('الكورنيش النيل')]),
    City('أسوان الجديدة', []),
    City('كوم أمبو', []),
    City('إدفو', []),
    City('دراو', []),
    City('نصر النوبة', []),
  ]),

  // محافظة البحر الأحمر
  Governorate('البحر الأحمر', [
    City('الغردقة', [District('وسط الغردقة'), District('سهل حشيش')]),
    City('الغردقة الجديدة', []),
    City('سفاجا', []),
    City('القصير', []),
    City('مرسى علم', []),
    City('رأس غارب', []),
    City('شلاتين', []),
    City('حلايب', []),
  ]),

  // محافظة مطروح
  Governorate('مطروح', [
    City('مرسى مطروح', [District('وسط مرسى مطروح'), District('سهلية')]),
    City('الحمام', []),
    City('العلمين', []),
    City('الضبعة', []),
    City('سيدي براني', []),
    City('السلوم', []),
    City('سيوة', []),
  ]),

  // محافظة الوادي الجديد
  Governorate('الوادي الجديد', [
    City('الخارجة', [District('وسط الخارجة'), District('واحة باريس')]),
    City('الداخلة', []),
    City('الفرافرة', []),
    City('باريس', []),
    City('بلاط', []),
  ]),

  // محافظة شمال سيناء
  Governorate('شمال سيناء', [
    City('العريش', [District('وسط العريش')]),
    City('الشيخ زويد', []),
    City('رفح', []),
    City('بئر العبد', []),
    City('الحسنة', []),
    City('نخل', []),
  ]),

  // محافظة جنوب سيناء
  Governorate('جنوب سيناء', [
    City('شرم الشيخ', [District('خليج نعمة'), District('السوق القديم')]),
    City('الطور', []),
    City('دهب', []),
    City('نويبع', []),
    City('طابا', []),
    City('سانت كاترين', []),
    City('رأس سدر', []),
    City('أبو رديس', []),
    City('أبو زنيمة', []),
  ]),
];

/// Helper function to get cities for a specific governorate
List<City> getCitiesForGovernorate(String governorateName) {
  try {
    return egyptianLocations
        .firstWhere((gov) => gov.name == governorateName)
        .cities;
  } catch (e) {
    return [];
  }
}

/// Helper function to get districts for a specific city in a governorate
List<District> getDistrictsForCity(String governorateName, String cityName) {
  try {
    final governorate = egyptianLocations.firstWhere(
      (gov) => gov.name == governorateName,
    );
    final city = governorate.cities.firstWhere((c) => c.name == cityName);
    return city.districts;
  } catch (e) {
    return [];
  }
}

/// Get list of governorate names only
List<String> getGovernorateNames() {
  return egyptianLocations.map((gov) => gov.name).toList();
}

/// Get list of city names for a governorate
List<String> getCityNames(String governorateName) {
  return getCitiesForGovernorate(
    governorateName,
  ).map((city) => city.name).toList();
}

/// Get list of district names for a city
List<String> getDistrictNames(String governorateName, String cityName) {
  return getDistrictsForCity(
    governorateName,
    cityName,
  ).map((district) => district.name).toList();
}
