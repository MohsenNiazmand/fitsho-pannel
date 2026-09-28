# APP METADATA / SHARED CATALOG FEATURE - Admin Panel (Flutter)

## هدف کلی
اضافه کردن یک فاز جدید به پنل ادمین برای مدیریت کامل متادیتای مشترک پلتفرم. ادمین می‌تواند عضلات، دسته‌بندی‌ها، تجهیزات و سایر catalog itemها را مستقیماً از پنل اضافه، ویرایش و حذف کند. هر تغییر باعث افزایش شماره نسخه می‌شود و اپ موبایل کاربر به‌صورت خودکار کاتالوگ را بروزرسانی می‌کند.

## معماری کلی فیچر

```
Admin Panel
  └── MetadataScreen
        ├── Tab برای هر نوع (muscle_group, equipment, ...)
        ├── لیست آیتم‌ها با drag-to-reorder
        └── دیالوگ Add/Edit
              ├── فیلد key (انگلیسی، یکتا در هر type)
              ├── فیلد labelFa
              ├── فیلد labelEn
              ├── فیلد icon (اختیاری)
              └── toggle isActive
```

## انواع متادیتا قابل مدیریت

| نوع | برچسب فارسی در UI |
|---|---|
| `muscle_group` | گروه‌های عضلانی |
| `exercise_category` | دسته‌بندی حرکات |
| `movement_pattern` | الگوی حرکتی |
| `workout_type` | نوع تمرین |
| `equipment` | تجهیزات ورزشی |
| `injury_type` | انواع آسیب |
| `goal` | اهداف تمرین |
| `difficulty_level` | سطح دشواری |

---

## فازهای توسعه

### Phase 6: Domain & Data Layer (✅ Done)
**هدف:** پیاده‌سازی لایه‌های domain و data برای ارتباط با API متادیتا.

**تسک‌ها:**

1. ایجاد `lib/features/metadata/domain/entities/metadata_item.dart`:
```dart
class MetadataItem {
  final String id;
  final String type;
  final String key;
  final String labelFa;
  final String labelEn;
  final String? icon;
  final int order;
  final bool isActive;
  final Map<String, dynamic>? extraData;
}
```

2. ایجاد `lib/features/metadata/domain/entities/metadata_catalog.dart`:
```dart
class MetadataCatalog {
  final int version;
  final DateTime updatedAt;
  final Map<String, List<MetadataItem>> catalog;
}
```

3. ایجاد `lib/features/metadata/domain/repositories/metadata_repository.dart` (abstract)

4. ایجاد `lib/features/metadata/data/models/metadata_item_model.dart` با `json_serializable`

5. اضافه کردن endpoints به `lib/core/network/admin_api_service.dart`:
   - `GET /admin/metadata` با query params `type`, `page`, `limit`
   - `POST /admin/metadata`
   - `PUT /admin/metadata/{id}`
   - `DELETE /admin/metadata/{id}`
   - `PATCH /admin/metadata/reorder`

6. ایجاد `lib/features/metadata/data/repositories/metadata_repository_impl.dart`

7. اجرای `flutter pub run build_runner build --delete-conflicting-outputs`

**Commit Message:** `feat(metadata): implement metadata domain entities and data layer`

---

### Phase 7: Presentation Layer - Provider
**هدف:** پیاده‌سازی state management برای مدیریت متادیتا.

**تسک‌ها:**

1. ایجاد `lib/features/metadata/presentation/providers/metadata_admin_provider.dart`:

**State:**
```dart
class MetadataAdminState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String selectedType;       // نوع انتخاب‌شده در tab
  final List<MetadataItem> items;  // آیتم‌های نوع انتخاب‌شده
  final bool isSubmitting;
  final int currentVersion;
}
```

**Notifier Methods:**
- `fetchItems(String type)` → دریافت آیتم‌های یک نوع خاص
- `selectType(String type)` → تغییر tab و دریافت آیتم‌ها
- `createItem(Map<String, dynamic> data)` → ایجاد آیتم جدید
- `updateItem(String id, Map<String, dynamic> data)` → ویرایش
- `deleteItem(String id)` → حذف با تأیید
- `reorderItems(List<String> orderedIds)` → تغییر ترتیب

2. نوشتن تست در `test/features/metadata/metadata_admin_test.dart`

**Commit Message:** `feat(metadata): implement metadata admin state provider`

---

### Phase 8: Presentation Layer - UI Screen
**هدف:** پیاده‌سازی صفحه مدیریت متادیتا با رابط کاربری پریمیوم.

**تسک‌ها:**

1. ایجاد `lib/features/metadata/presentation/screens/metadata_screen.dart`:
   - Header با عنوان «مدیریت کاتالوگ پلتفرم» و نمایش شماره نسخه فعلی
   - TabBar افقی و scrollable برای هر ۸ نوع متادیتا
   - لیست آیتم‌ها برای tab انتخاب‌شده با drag-to-reorder (`ReorderableListView`)
   - هر آیتم: برچسب فارسی + کلید انگلیسی + badge وضعیت (فعال/غیرفعال) + دکمه‌های ویرایش و حذف
   - دکمه «افزودن آیتم جدید» در header
   - Loading skeleton هنگام دریافت داده

2. ایجاد دیالوگ `lib/features/metadata/presentation/screens/metadata_form_dialog.dart`:
   - فیلد `key` (انگلیسی snake_case، در حالت ویرایش disabled)
   - فیلد `labelFa` (فارسی)
   - فیلد `labelEn` (انگلیسی)
   - فیلد `icon` (اختیاری)
   - toggle `isActive`
   - دکمه ذخیره با loading state

3. اضافه کردن route `/metadata` به `lib/core/routes/app_router.dart`

4. اضافه کردن آیتم «کاتالوگ» به sidebar در `lib/shared/presentation/widgets/responsive_scaffold.dart`

5. نوشتن widget test

**Commit Message:** `feat(metadata): implement metadata management screen and form dialog`

---

## نکات مهم پیاده‌سازی

- **Type Safety**: نوع `selectedType` باید از یک enum یا const string list باشد تا typo نشود
- **Optimistic UI**: بعد از delete یا reorder فوراً UI آپدیت شود، سپس API call انجام شود
- **Version Badge**: در header نمایش نسخه فعلی کاتالوگ نمایش داده شود تا ادمین بداند کاربران چه نسخه‌ای دارند
- **Confirmation Dialog**: قبل از حذف یک آیتم، تأییدیه گرفته شود و warning نمایش داده شود که این تغییر روی اپ کاربران تأثیر می‌گذارد

---
*پس از اتمام هر فاز، کامیت انجام و (✅ Done) جلوی نام فاز قرار گیرد.*
