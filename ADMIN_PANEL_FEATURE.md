# FitSho Admin Panel - Frontend Development Plan

این سند مراحل توسعه فاز به فاز پروژه `fitsho_pannel` (پنل مدیریت) را شرح می‌دهد. این فایل به عنوان یک "نقشه راه" (Roadmap) عمل می‌کند تا هر AI Agent با خواندن آن بتواند توسعه را از همان نقطه ادامه دهد.

## معماری و تکنولوژی‌ها
- **Architecture:** Clean Architecture (لایه بندی: Domain, Data, Presentation)
- **State Management:** Riverpod
- **Networking:** Dio + Retrofit
- **Routing:** GoRouter
- **Responsive UI:** Bottom Navigation Bar برای موبایل/تبلت، Sidebar (NavigationRail/Drawer) برای دسکتاپ و وب.
- **رویکرد:** MVP (حداقل محصول پذیرفتنی) - سبک، سریع و کارآمد.

## قوانین مهم برای AI Agent
۱. **فازبندی اکید:** هر فاز باید به صورت کامل انجام شود.
۲. **کامیت پیام:** در انتهای هر فاز، AI موظف است پیام کامیت (Commit Message) مربوطه را به کاربر نمایش دهد و **متوقف شود**. تا زمانی که کاربر کامیت را انجام نداده و تایید نکرده، فاز بعدی شروع **نمی‌شود**.
۳. **ساختار مشابه اپ کاربر:** تمام الگوها (نحوه تعریف مِپرها، استفاده از Freezed/JsonSerializable، هندل کردن خطاها و تعریف UseCaseها) باید دقیقاً مشابه سورس اپلیکیشن کاربری `FitSho` باشد.

---

## لیست API Endpoint های مورد نیاز (API Service Layer)
این اندپوینت‌ها در فایل `AdminApiService` (Retrofit) پیاده‌سازی خواهند شد:
- `POST /api/v1/admin/auth/login` (ورود ادمین)
- `GET /api/v1/admin/dashboard/stats` (آمار کلی: تعداد کاربران، برنامه‌ها و...)
- `GET /api/v1/admin/users` (لیست کاربران با Pagination)
- `GET /api/v1/admin/users/{id}` (جزئیات کامل یک کاربر شامل پروفایل و برنامه‌های او)
- `GET /api/v1/admin/exercises` (لیست حرکات ورزشی)
- `POST /api/v1/admin/exercises` (افزودن حرکت جدید)
- `PUT /api/v1/admin/exercises/{id}` (ویرایش حرکت)

---

## فازهای توسعه (Development Phases)

### Phase 1: Project Skeleton & Responsive Layout (✅ Done)
**هدف:** راه‌اندازی ساختار پایه پروژه و ایجاد قالب (Shell) ریسپانسیو.
- **تسک‌ها:**
  - تنظیم وابستگی‌ها (Dependencies) در `pubspec.yaml` (شامل flutter_riverpod، dio، retrofit، freezed، go_router و...).
  - ایجاد ساختار پوشه‌بندی Clean Architecture برای `core` و `shared`.
  - پیاده‌سازی یک ویجت `ResponsiveScaffold` یا `AdminShell` که با `LayoutBuilder` چک می‌کند: اگر عرض صفحه کمتر از 800 پیکسل بود `BottomNavigationBar` نشان دهد و اگر بیشتر بود `Row` شامل `NavigationRail` یا `SideMenu` رندر شود.
  - راه‌اندازی اولیه `GoRouter` برای مسیرهای داشبورد، کاربران و تمرینات.
- **Commit Message:** `chore: setup project skeleton and responsive admin shell`

### Phase 2: Core Network Layer & Authentication (✅ Done)
**هدف:** تنظیم کلاینت شبکه، Retrofit و ورود ادمین.
- **تسک‌ها:**
  - ایجاد تنظیمات `Dio` به همراه Interceptor برای ارسال توکن ادمین (Token Auth).
  - ایجاد رابط (interface) `AdminApiService` با استفاده از `@RestApi`.
  - پیاده‌سازی `AuthRepository` و `LoginUseCase` برای ادمین.
  - پیاده‌سازی صفحه `LoginScreen` و مدیریت State آن در Riverpod (با در نظر گرفتن Guard برای GoRouter که اگر توکن نبود، ریدایرکت شود).
- **Commit Message:** `feat(auth): implement admin login and dio network layer`

### Phase 3: Dashboard Feature (MVP) (✅ Done)
**هدف:** نمایش آمار کلی اپلیکیشن.
- **تسک‌ها:**
  - ساخت Entity و Model برای `DashboardStats` (مثلاً totalUsers, totalWorkoutPlans, totalDietPlans).
  - اضافه کردن متد به `AdminApiService`.
  - ایجاد `DashboardRepository` و `GetDashboardStatsUseCase`.
  - ایجاد صفحه `DashboardScreen` و نمایش داده‌ها به صورت کارت‌های آماری زیبا.
- **Commit Message:** `feat(dashboard): implement dashboard analytics view`

### Phase 4: Users Management Feature (✅ Done)
**هدف:** مشاهده لیست کاربران و جستجو/فیلتر در آن‌ها.
- **تسک‌ها:**
  - اضافه کردن API لیست کاربران به `AdminApiService`.
  - پیاده‌سازی `UserRepository`، Model ها و Entity ها.
  - ایجاد `UsersScreen` شامل جدول (DataTable) یا لیست (ListView) کاربران با قابلیت صفحه‌بندی (Pagination) و جستجو.
  - (اختیاری در MVP) صفحه `UserDetailsScreen` برای دیدن اطلاعات کامل یک کاربر خاص.
- **Commit Message:** `feat(users): implement users management list`

### Phase 5: Exercises Catalog Management (✅ Done)
**هدف:** امکان مدیریت دیتابیس حرکات از روی پنل ادمین.
- **تسک‌ها:**
  - اضافه کردن CRUD کامل حرکات به `AdminApiService`.
  - ایجاد `ExerciseRepository` و `Exercise` Entities.
  - صفحه `ExercisesScreen` برای لیست حرکات با نمایش Thumbnail تصویر/GIF.
  - دیالوگ یا فرم در صفحه جدید برای `Add/Edit Exercise` جهت ویرایش `gifUrl`, `videoUrl` و اطلاعات حرکات.
- **Commit Message:** `feat(exercises): implement exercises catalog management`

---
*پس از اتمام هر مرحله، تیک (✅ Done) جلوی نام فاز قرار داده شود.*
