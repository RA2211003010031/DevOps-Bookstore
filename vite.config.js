import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  base: '/', // Changed from '/DevOps-Bookstore/' to serve at root
  plugins: [react()],
});