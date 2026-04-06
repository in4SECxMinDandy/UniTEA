# Tài liệu Clone Dự án UniTEA - Hướng dẫn chi tiết từ Backend

## Mục lục

1. [Tổng quan dự án](#1-tổng-quan-dự-án)
2. [Yêu cầu hệ thống](#2-yêu-cầu-hệ-thống)
3. [Cấu trúc thư mục](#3-cấu-trúc-thư-mục)
4. [Database Schema](#4-database-schema)
5. [Cấu hình Environment Variables](#5-cấu-hình-environment-variables)
6. [Supabase Setup](#6-supabase-setup)
7. [Cài đặt và chạy dự án](#7-cài-đặt-và-chạy-dự-án)
8. [Tạo tài khoản Admin đầu tiên](#8-tạo-tài-khoản-admin-đầu-tiên)
9. [Kiến trúc & Mẫu code quan trọng](#9-kiến-trúc--mẫu-code-quan-trọng)
10. [Cấu hình Supabase Dashboard](#10-cấu-hình-supabase-dashboard)

---

## 1. Tổng quan dự án

**UniTEA** là nền tảng F&B (Food & Beverage) được xây dựng với:

| Thành phần | Công nghệ | Phiên bản |
|------------|-----------|-----------|
| Frontend Framework | Next.js | 15.x (App Router) |
| UI Library | React | 19.x |
| Styling | Tailwind CSS | 3.4.x |
| Backend/Auth/Database | Supabase | Cloud |
| Realtime | Supabase Realtime | - |
| Language | TypeScript | 5.7.x |
| Package Manager | npm | - |

### Các tính năng chính:
- **Trang chủ**: Hiển thị món ăn nổi bật
- **Danh mục thực phẩm**: Xem theo phân loại
- **Chat realtime**: Khách hàng chat với nhân viên qua QR code
- **Admin Dashboard**: Quản lý món ăn, danh mục, đơn hàng, chat
- **Xác thực**: Đăng ký/đăng nhập cho user, anonymous sign-in cho khách

---

## 2. Yêu cầu hệ thống

```bash
# Phiên bản tối thiểu
Node.js: >= 18.x
npm: >= 9.x (đi kèm Node.js 18+)
Git: >= 2.x

# Khuyến nghị
Node.js: 20.x LTS
npm: 10.x
```

Kiểm tra phiên bản:
```bash
node --version
npm --version
git --version
```

---

## 3. Cấu trúc thư mục

```
UniTEA/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── admin/
│   │   │   ├── layout.tsx            # Admin layout với sidebar + RoleGate
│   │   │   ├── page.tsx              # Dashboard admin
│   │   │   ├── chat/
│   │   │   │   └── page.tsx         # Admin chat panel
│   │   │   ├── foods/
│   │   │   │   └── page.tsx         # Quản lý món ăn
│   │   │   ├── categories/
│   │   │   │   └── page.tsx         # Quản lý danh mục
│   │   │   └── orders/
│   │   │       └── page.tsx          # Quản lý đơn hàng
│   │   ├── chat/
│   │   │   ├── page.tsx              # Trang chat cho khách
│   │   │   └── ChatContent.tsx      # Component chat content
│   │   ├── thuc-pham/
│   │   │   ├── page.tsx             # Trang danh sách thực phẩm
│   │   │   └── [slug]/
│   │   │       └── page.tsx         # Chi tiết thực phẩm
│   │   ├── login/
│   │   │   └── page.tsx             # Trang đăng nhập
│   │   ├── history/
│   │   │   └── page.tsx             # Lịch sử đơn hàng
│   │   ├── gioi-thieu/
│   │   │   └── page.tsx             # Trang giới thiệu
│   │   ├── layout.tsx               # Root layout (Header + Footer)
│   │   ├── page.tsx                 # Trang chủ
│   │   ├── globals.css              # Tailwind + custom components
│   │   ├── error.tsx                # Error boundary
│   │   └── loading.tsx              # Loading state
│   ├── components/
│   │   ├── admin/
│   │   │   ├── FoodFormModal.tsx     # Modal thêm/sửa món
│   │   │   └── AdminChatPanel.tsx   # Panel chat admin
│   │   ├── auth/
│   │   │   ├── RoleGate.tsx         # Bảo vệ route theo role
│   │   │   └── TurnstileBox.tsx     # CAPTCHA integration
│   │   ├── layout/
│   │   │   ├── Header.tsx           # Header navigation
│   │   │   └── Footer.tsx           # Footer
│   │   └── food/
│   │       ├── FoodCard.tsx         # Card hiển thị món ăn
│   │       └── OrderForm.tsx        # Form đặt hàng
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts            # Browser client với debug logging
│   │   │   └── server.ts           # Server-side client
│   │   ├── utils.ts                 # cn(), formatPrice(), formatTime()
│   │   └── types.ts                 # TypeScript interfaces
│   └── middleware.ts               # Next.js middleware cho Supabase SSR
├── supabase/
│   ├── migrations/                  # 17 file SQL migration
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_fix_search_path_security.sql
│   │   ├── 003_fix_chat_rls_token.sql
│   │   ├── 004_chat_image_support.sql
│   │   ├── 005_fix_chat_messages_rls.sql
│   │   ├── 006_fix_food_images_storage.sql
│   │   ├── 007_admin_chat_rls.sql
│   │   ├── 008_anonymous_guest_chat.sql
│   │   ├── 009_enable_realtime.sql
│   │   ├── 010_admin_delete_chat.sql
│   │   ├── 011_chat_guest_identity.sql
│   │   ├── 012_fix_food_images_storage.sql
│   │   ├── 013_fix_food_image_urls.sql
│   │   ├── 014_create_orders_table.sql
│   │   ├── 015_orders_profiles_fk.sql
│   │   ├── 016_order_stock_trigger.sql
│   │   └── 017_admin_session_management.sql
│   ├── config.toml                  # Supabase CLI config
│   └── seed.sql                     # Dữ liệu mẫu
├── public/                          # Static assets
├── .env.example                     # Template biến môi trường
├── package.json
├── tsconfig.json
├── tailwind.config.ts
├── postcss.config.js
├── next.config.mjs
├── eslint.config.mjs
└── README.md
```

---

## 4. Database Schema

### 4.1 Tables chính

#### `profiles` - Hồ sơ người dùng
```sql
CREATE TABLE profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   text,
  phone       text,
  avatar_url  text,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now(),
  updated_at  timestamptz DEFAULT now()
);
```

#### `roles` - Vai trò
```sql
CREATE TABLE roles (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text UNIQUE NOT NULL,  -- 'STORE_ADMIN', 'USER'
  description text,
  created_at  timestamptz DEFAULT now()
);
```

#### `user_roles` - Mapping user-role
```sql
CREATE TABLE user_roles (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid REFERENCES profiles(id) ON DELETE CASCADE,
  role_id    uuid REFERENCES roles(id) ON DELETE CASCADE,
  granted_at timestamptz DEFAULT now(),
  granted_by uuid REFERENCES profiles(id),
  UNIQUE (user_id, role_id)
);
```

#### `food_categories` - Danh mục thực phẩm
```sql
CREATE TABLE food_categories (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  slug        text UNIQUE NOT NULL,
  image_url   text,
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);
```

#### `foods` - Thực phẩm (soft delete)
```sql
CREATE TABLE foods (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id    uuid REFERENCES food_categories(id) ON DELETE SET NULL,
  name           text NOT NULL,
  slug           text UNIQUE NOT NULL,
  description    text,
  price          numeric(15, 2) NOT NULL,
  image_url      text,
  is_available   boolean DEFAULT true,
  is_featured    boolean DEFAULT false,
  sort_order     integer DEFAULT 0,
  stock_quantity integer DEFAULT 0,
  deleted_at     timestamptz,  -- Soft delete
  created_by     uuid REFERENCES profiles(id),
  updated_by     uuid REFERENCES profiles(id),
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);
```

#### `visit_sessions` - Phiên khách (QR code)
```sql
CREATE TABLE visit_sessions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid REFERENCES profiles(id) ON DELETE CASCADE,
  visit_token      text UNIQUE NOT NULL,
  table_label      text,
  started_at       timestamptz DEFAULT now(),
  expires_in_hours integer DEFAULT 3,
  expires_at       timestamptz NOT NULL,  -- Auto-calculated
  is_active        boolean DEFAULT true,
  created_by       uuid REFERENCES profiles(id)
);
```

#### `chat_sessions` - Phiên chat
```sql
CREATE TABLE chat_sessions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          uuid REFERENCES profiles(id) ON DELETE CASCADE,
  visit_session_id uuid REFERENCES visit_sessions(id) ON DELETE SET NULL,
  title            text,
  status           chat_status DEFAULT 'open',  -- ENUM: open, closed
  opened_at        timestamptz DEFAULT now(),
  closed_at        timestamptz,
  last_message_at  timestamptz DEFAULT now(),
  guest_name       text,  -- Optional display name for QR guests
  session_type     text DEFAULT 'qr'  -- 'qr' | 'account'
);
```

#### `chat_messages` - Tin nhắn chat
```sql
CREATE TABLE chat_messages (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id  uuid REFERENCES chat_sessions(id) ON DELETE CASCADE,
  sender_id   uuid REFERENCES profiles(id),
  sender_role text NOT NULL,  -- 'admin', 'user', 'guest'
  content     text NOT NULL,
  is_read     boolean DEFAULT false,
  created_at  timestamptz DEFAULT now()
);
```

#### `orders` - Đơn hàng
```sql
CREATE TABLE orders (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  food_id     UUID NOT NULL REFERENCES public.foods(id) ON DELETE RESTRICT,
  quantity    INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  note        TEXT,
  total_price BIGINT NOT NULL DEFAULT 0,
  status      TEXT NOT NULL DEFAULT 'pending'
              CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4.2 Helper Functions

```sql
-- Kiểm tra role của user
CREATE FUNCTION public.has_role(uid uuid, role_name text)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN roles r ON r.id = ur.role_id
    WHERE ur.user_id = uid AND r.name = role_name
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Kiểm tra phiên visit còn hạn
CREATE FUNCTION public.has_valid_visit_session(uid uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM visit_sessions
    WHERE user_id = uid AND is_active = true AND expires_at > now()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
```

### 4.3 Triggers

| Trigger | Bảng | Sự kiện | Hành động |
|---------|------|---------|-----------|
| `foods_updated_at` | foods | UPDATE | Cập nhật `updated_at` |
| `profiles_updated_at` | profiles | UPDATE | Cập nhật `updated_at` |
| `foods_soft_delete` | foods | DELETE | Set `deleted_at = now()` |
| `visit_session_auto_expires` | visit_sessions | INSERT | Tính `expires_at` |
| `chat_messages_new_message` | chat_messages | INSERT | Cập nhật `last_message_at` |
| `on_auth_user_created` | auth.users | INSERT | Tạo profile + gán role USER |
| `tr_order_stock` | orders | INSERT/UPDATE | Quản lý tồn kho |

### 4.4 RLS Policies (Row Level Security)

```sql
-- Profiles: users see/update their own
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Food categories: read all, admin write
CREATE POLICY "food_categories_select" ON food_categories FOR SELECT USING (true);
CREATE POLICY "food_categories_admin_write" ON food_categories FOR ALL USING (has_role(auth.uid(), 'STORE_ADMIN'));

-- Foods: read all (except soft-deleted), admin all
CREATE POLICY "foods_select" ON foods FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "foods_admin_all" ON foods FOR ALL USING (has_role(auth.uid(), 'STORE_ADMIN'));

-- Chat: admin read all, users read own
CREATE POLICY "chat_sessions_read_admin" ON chat_sessions FOR SELECT USING (has_role(auth.uid(), 'STORE_ADMIN'));
CREATE POLICY "chat_sessions_select" ON chat_sessions FOR SELECT USING (has_role(auth.uid(), 'STORE_ADMIN') OR user_id = auth.uid());

-- Orders: users see own, admins see all
-- (xem chi tiết trong migration 014)
```

### 4.5 Realtime Configuration

```sql
-- Bật realtime cho các bảng chat
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_sessions;
```

---

## 5. Cấu hình Environment Variables

Tạo file `.env.local` tại thư mục gốc của dự án:

```bash
# Supabase Configuration (BẮT BUỘC)
NEXT_PUBLIC_SUPABASE_URL=https://[YOUR_PROJECT_ID].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here

# Optional: Cloudflare Turnstile CAPTCHA
# Required nếu Supabase Auth có bật Bot Protection
NEXT_PUBLIC_TURNSTILE_SITE_KEY=
```

### Cách lấy thông tin từ Supabase Dashboard:

1. Truy cập [Supabase Dashboard](https://supabase.com/dashboard)
2. Chọn project của bạn
3. Vào **Settings** → **API**
4. Copy:
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

---

## 6. Supabase Setup

### 6.1 Tạo Supabase Project

1. Truy cập [supabase.com](https://supabase.com) và đăng nhập
2. Click **New Project**
3. Điền thông tin:
   - **Name**: UniTEA (hoặc tên bạn chọn)
   - **Database Password**: Tạo password mạnh, lưu lại
   - **Region**: Chọn region gần nhất (Singapore cho Việt Nam)
4. Click **Create new project**
5. Đợi project khởi tạo (~2 phút)

### 6.2 Bật Anonymous Sign-in

1. Trong Supabase Dashboard → **Authentication** → **Providers**
2. Tìm **Anonymous Sign-ins** (phía dưới)
3. Click **Enable**
4. (Optional) Cấu hình rate limit nếu cần

### 6.3 Push Database Migrations

```bash
# Cài đặt Supabase CLI toàn cục (nếu chưa có)
npm install -g supabase

# Login vào Supabase CLI
npx supabase login

# Link project với local
# Thay [YOUR_PROJECT_ID] bằng Project ID từ Supabase Dashboard
npx supabase link --project-ref [YOUR_PROJECT_ID]

# Push migrations lên cloud
npx supabase db push

# (Tùy chọn) Reset database về trạng thái ban đầu
# npx supabase db reset
```

### 6.4 Kiểm tra Database

Sau khi push thành công, kiểm tra trong Supabase Dashboard → **Table Editor**:

- [ ] `profiles` table
- [ ] `roles` table (có 2 rows: STORE_ADMIN, USER)
- [ ] `user_roles` table
- [ ] `food_categories` table
- [ ] `foods` table
- [ ] `visit_sessions` table
- [ ] `chat_sessions` table
- [ ] `chat_messages` table
- [ ] `orders` table

### 6.5 Cấu hình Storage (Optional - cho hình ảnh)

Nếu muốn lưu trữ hình ảnh món ăn:

1. Supabase Dashboard → **Storage** → **New bucket**
2. Tên bucket: `food-images`
3. Public bucket: **Yes**
4. Cấu hình RLS:
```sql
-- Cho phép đọc công khai
CREATE POLICY "Public read access" ON storage.objects
  FOR SELECT USING (bucket_id = 'food-images');

-- Chỉ admin được upload
CREATE POLICY "Admin upload" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'food-images' 
    AND has_role(auth.uid(), 'STORE_ADMIN')
  );

-- Admin được xóa
CREATE POLICY "Admin delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'food-images'
    AND has_role(auth.uid(), 'STORE_ADMIN')
  );
```

---

## 7. Cài đặt và chạy dự án

### 7.1 Clone Repository

```bash
# Clone từ GitHub
git clone https://github.com/in4SECxMinDandy/UniTEA.git

# Di chuyển vào thư mục
cd UniTEA
```

### 7.2 Cài đặt Dependencies

```bash
# Cài đặt tất cả dependencies
npm install

# Hoặc cài đặt thủ công từng phần nếu gặp lỗi
npm install --legacy-peer-deps
```

### 7.3 Cấu hình Environment

```bash
# Tạo file .env.local từ .env.example
cp .env.example .env.local

# Mở file và điền thông tin Supabase
# Sử dụng code editor hoặc:
notepad .env.local  # Windows
# nano .env.local    # macOS/Linux
```

### 7.4 Chạy Development Server

```bash
npm run dev
```

### 7.5 Truy cập Ứng dụng

| Trang | URL | Mô tả |
|-------|-----|--------|
| Trang chủ | http://localhost:3000 | Trang chủ với món nổi bật |
| Thực phẩm | http://localhost:3000/thuc-pham | Danh sách tất cả món |
| Giới thiệu | http://localhost:3000/gioi-thieu | Trang giới thiệu |
| Đăng nhập | http://localhost:3000/login | Trang đăng nhập/đăng ký |
| Admin | http://localhost:3000/admin | Dashboard admin (cần quyền) |

---

## 8. Tạo tài khoản Admin đầu tiên

### 8.1 Tạo User qua Dashboard

1. Supabase Dashboard → **Authentication** → **Users**
2. Click **Add user** → **Create new user**
3. Điền thông tin:
   - **Email**: admin@unitea.local (hoặc email thật)
   - **Password**: Password mạnh
   - **Email confirmed**: ✓ (tick)
4. Click **Create user**

### 8.2 Gán Role STORE_ADMIN

Có 2 cách:

#### Cách 1: Qua Supabase Dashboard (Đơn giản)

1. Truy cập **Table Editor** → `user_roles`
2. Click **Insert row**:
   - `user_id`: UUID của user (copy từ bảng auth.users)
   - `role_id`: UUID của role STORE_ADMIN (copy từ bảng roles)
   - `granted_at`: `now()`
3. Click **Insert**

#### Cách 2: Qua SQL Editor

```sql
-- Tìm role_id của STORE_ADMIN
SELECT id, name FROM roles WHERE name = 'STORE_ADMIN';

-- Tìm user_id của admin user
SELECT id, email FROM auth.users WHERE email = 'admin@unitea.local';

-- Gán role (thay các giá trị UUID thực tế)
INSERT INTO user_roles (user_id, role_id, granted_at)
VALUES ('[USER_UUID]', '[ROLE_UUID]', now());
```

### 8.3 Đăng nhập Admin

1. Truy cập http://localhost:3000/login
2. Đăng nhập với email/password đã tạo
3. Truy cập http://localhost:3000/admin
4. Sidebar admin sẽ hiển thị với các mục:
   - Dashboard
   - Đơn hàng (badge hiển thị số pending)
   - Quản lý món
   - Phân loại
   - Chat (badge hiển thị số chat open)

---

## 9. Kiến trúc & Mẫu code quan trọng

### 9.1 Supabase Client Pattern

#### Browser Client (Client Components)
```typescript
// src/lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

#### Server Client (Server Components)
```typescript
// src/lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {}
        },
      },
    }
  )
}
```

### 9.2 Middleware cho SSR Auth

```typescript
// src/middleware.ts
import { createServerClient } from '@supabase/ssr'
import { type NextRequest, NextResponse } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  await supabase.auth.getUser()
  await supabase.auth.getSession()

  return supabaseResponse
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
}
```

### 9.3 RoleGate Component

```typescript
// src/components/auth/RoleGate.tsx
'use client'
import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import { ShieldOff, Loader2 } from 'lucide-react'

export function RoleGate({ role, children }: { role: string; children: React.ReactNode }) {
  const [hasRole, setHasRole] = useState<boolean | null>(null)
  const router = useRouter()
  const supabase = createClient()

  useEffect(() => {
    async function check() {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) { router.push('/login'); return }

      const { data } = await supabase.rpc('has_role', { uid: user.id, role_name: role })
      setHasRole(data === true)
    }
    check()
  }, [])

  if (hasRole === null) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[40vh] gap-3">
        <Loader2 size={24} className="text-text-muted animate-spin" />
        <p className="text-sm text-text-muted">Đang kiểm tra quyền truy cập...</p>
      </div>
    )
  }

  if (!hasRole) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[40vh] text-center px-4">
        <ShieldOff size={28} className="text-accent-red" />
        <h3>Không có quyền truy cập</h3>
      </div>
    )
  }

  return <>{children}</>
}
```

### 9.4 Realtime Subscription Pattern

```typescript
// Admin chat panel - realtime subscription
useEffect(() => {
  // Load initial data
  loadSessions()

  // Subscribe to changes
  const channel = supabase
    .channel('admin-chat-realtime')
    .on('postgres_changes', 
      { event: '*', schema: 'public', table: 'chat_sessions' },
      () => { loadSessions() }
    )
    .on('postgres_changes',
      { event: 'INSERT', schema: 'public', table: 'chat_messages' },
      (payload) => { handleNewMessage(payload.new) }
    )
    .subscribe()

  return () => {
    supabase.removeChannel(channel)
  }
}, [])
```

### 9.5 Data Fetching Pattern

#### Server Component (Recommended)
```typescript
// src/app/thuc-pham/page.tsx
import { createClient } from '@/lib/supabase/server'

export default async function FoodsPage() {
  const supabase = await createClient()
  
  const { data: foods } = await supabase
    .from('foods')
    .select('*, category:food_categories(name)')
    .eq('is_available', true)
    .is('deleted_at', null)
    .order('sort_order')

  return <FoodGrid foods={foods} />
}
```

#### Client Component (Khi cần interactivity)
```typescript
// src/components/food/FoodCard.tsx
'use client'
import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'

export default function FoodCard({ food }: { food: Food }) {
  const [imageUrl, setImageUrl] = useState<string | null>(null)

  useEffect(() => {
    if (food.image_url) {
      createClient().storage
        .from('food-images')
        .createSignedUrl(food.image_url, 3600)
        .then(({ data }) => setImageUrl(data?.signedUrl ?? null))
    }
  }, [food.image_url])

  return <div>...</div>
}
```

---

## 10. Cấu hình Supabase Dashboard

### 10.1 Authentication Settings

1. **Authentication** → **URL Configuration**
   - **Site URL**: `http://localhost:3000` (dev) / `https://your-domain.com` (prod)
   - **Redirect URLs**: Thêm `http://localhost:3000/**`

2. **Authentication** → **Email**
   - **Enable Sign Up**: ✓
   - **Double confirm changes**: ✓ (Khuyến nghị)

3. **Authentication** → **Providers** → **Anonymous Sign-ins**
   - **Enable**: ✓

### 10.2 Database Permissions

Đảm bảo các policies đã được tạo đúng bằng cách kiểm tra:

1. **Table Editor** → Click vào table → **Policies** tab
2. Hoặc chạy SQL trong **SQL Editor**:

```sql
-- Kiểm tra tất cả policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename NOT LIKE 'pg_%'
ORDER BY tablename, policyname;
```

### 10.3 Realtime Settings

1. **Database** → **Replication**
2. Kiểm tra `chat_messages` và `chat_sessions` đã được enable trong publication `supabase_realtime`

---

## Checklist Clone hoàn chỉnh

```markdown
## Pre-clone
- [ ] Node.js 18+ đã cài đặt
- [ ] Git đã cài đặt
- [ ] Tài khoản Supabase đã có

## Supabase Setup
- [ ] Tạo Supabase project mới
- [ ] Lấy URL và ANON_KEY
- [ ] Bật Anonymous Sign-ins
- [ ] Push tất cả migrations (17 files)
- [ ] Kiểm tra seed data đã chạy

## Local Setup  
- [ ] Clone repository
- [ ] Chạy npm install
- [ ] Tạo .env.local với Supabase credentials
- [ ] Chạy npm run dev

## Admin Setup
- [ ] Tạo user admin qua Supabase Dashboard
- [ ] Gán role STORE_ADMIN cho user
- [ ] Đăng nhập và truy cập /admin
- [ ] Kiểm tra các chức năng admin

## Verify Features
- [ ] Trang chủ load với animation
- [ ] Xem danh sách thực phẩm
- [ ] Đăng nhập/đăng ký user
- [ ] Admin: Quản lý món ăn (CRUD)
- [ ] Admin: Quản lý danh mục
- [ ] Admin: Xem đơn hàng
- [ ] Admin: Chat panel hoạt động
```

---

## Troubleshooting

### Lỗi "Cannot connect to Supabase"

```bash
# Kiểm tra credentials trong .env.local
cat .env.local

# Verify URL format: https://xxxxx.supabase.co
# Verify ANON_KEY format: eyJhbGc...
```

### Lỗi "RLS Policy denied"

```sql
-- Kiểm tra user đã đăng nhập chưa
SELECT auth.uid();

-- Kiểm tra role của user
SELECT * FROM user_roles WHERE user_id = auth.uid();

-- Kiểm tra trực tiếp
SELECT has_role(auth.uid(), 'STORE_ADMIN');
```

### Lỗi "Anonymous sign-in not enabled"

1. Supabase Dashboard → **Authentication** → **Providers**
2. Tìm **Anonymous Sign-ins**
3. Click **Enable**

### Lỗi "Realtime not working"

```sql
-- Kiểm tra realtime đã enable chưa
SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';

-- Enable nếu chưa có
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_sessions;
ALTER PUBLICATION supabase_realtime ADD TABLE visit_sessions;
```

---

## Liên hệ & Hỗ trợ

Nếu gặp vấn đề trong quá trình clone:

1. Kiểm tra **Console logs** trong trình duyệt
2. Kiểm tra **Network tab** cho các API requests
3. Kiểm tra **Supabase Dashboard logs**
4.tham khảo tài liệu [Supabase Docs](https://supabase.com/docs)

---

*Dokument này được tạo tự động từ cấu hình dự án UniTEA - 2026*
