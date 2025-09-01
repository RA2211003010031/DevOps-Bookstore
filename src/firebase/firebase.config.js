// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth } from "firebase/auth"; // This line was missing

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyC9neR3E4IavIXQlqwP-r01L4W3hSQMT5Y",
  authDomain: "devops-book-store.firebaseapp.com",
  projectId: "devops-book-store",
  storageBucket: "devops-book-store.firebasestorage.app",
  messagingSenderId: "253045352008",
  appId: "1:253045352008:web:7d198d0033b23210ccda7d",
  measurementId: "G-4XJ3P3E1FY"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

// Initialize Firebase Authentication and export it
export const auth = getAuth(app); // This line was missing

export default app;