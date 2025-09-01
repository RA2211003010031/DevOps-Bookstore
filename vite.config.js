import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: '/DevOps-Bookstore/', // <-- must match your repo name
  plugins: [react()],
});