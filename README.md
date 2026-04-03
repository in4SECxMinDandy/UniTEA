# UniTEA - Food Store Management

UniTEA is a modern web application for a food and beverage store, built with [Next.js](https://nextjs.org/) App Router, [React 19](https://react.dev/), [Tailwind CSS](https://tailwindcss.com/) for styling, and [Supabase](https://supabase.com/) for a scalable backend and authentication.

## 🚀 Features

- **Modern UI**: Styled with Tailwind CSS, `lucide-react` icons, and `clsx`/`tailwind-merge` for dynamic classes.
- **Robust Backend**: Integrated with Supabase (`@supabase/supabase-js`, `@supabase/ssr`) for database management, authentication, and server-side rendering.
- **QR Code Support**: Built-in support for generating QR codes (`qrcode.react`) for quick interactions (orders, menus, etc.).
- **Type Safety**: Fully built with TypeScript.
- **Performance**: Leveraging Next.js 15 features, React 19, and optimized build processes.

## 🛠️ Tech Stack

- **Framework**: [Next.js](https://nextjs.org) (v15+)
- **Library**: [React](https://react.dev) (v19)
- **Styling**: [Tailwind CSS](https://tailwindcss.com) (v3) + PostCSS + Autoprefixer
- **Icons**: [Lucide React](https://lucide.dev/)
- **Database & Auth**: [Supabase](https://supabase.com)
- **Language**: [TypeScript](https://www.typescriptlang.org/)

## 📂 Project Structure

- `src/app`: Next.js App Router pages and layouts.
- `src/components`: Reusable React UI components.
- `src/lib`: Utility functions, Supabase clients, and helpers.
- `src/middleware.ts`: Next.js middleware for handling authentications and route protections.
- `supabase`: Supabase configuration files.

## 💻 Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm, yarn, or pnpm
- A [Supabase](https://supabase.com/) Project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/in4SECxMinDandy/UniTEA.git
   cd UniTEA
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up Environment Variables:**
   Create a `.env.local` file based on `.env.example` and add your Supabase credentials:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
   ```

4. **Run the development server:**
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) in your browser to see the application.

## 📜 Scripts

- `npm run dev`: Starts the development server.
- `npm run build`: Builds the app for production.
- `npm run start`: Starts the production server.
- `npm run lint`: Runs ESLint to check for code quality.

## 📝 License

This project is private and intended for internal use.
