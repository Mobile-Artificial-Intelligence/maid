import type { Metadata } from "next";
import Link from "next/link";
import Image from "next/image";
import { Geist, Space_Mono } from "next/font/google";
import "./globals.css";
import Script from "next/script";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const spaceMono = Space_Mono({
  variable: "--font-space-mono",
  weight: ["400", "700"],
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Mobile Artificial Intelligence",
  description: "Mobile Artifical Intelligence specializes in creating AI-powered mobile applications that enhance user experience and provide intelligent assistance.",
  keywords: [
    "Mobile AI",
    "Mobile Artificial Intelligence",
    "Mobile AI Apps",
    "AI Maid",
    "AI Assistant",
    "AI Girlfriend",
    "AI Boyfriend",
    "AI Chatbot",
    "AI Companion",
    "AI Friend"
  ],
  openGraph: {
    title: "Mobile Artificial Intelligence",
    description: "Mobile Artifical Intelligence specializes in creating AI-powered mobile applications that enhance user experience and provide intelligent assistance.",
    url: "https://mobile-artificial-intelligence.com",
    siteName: "Mobile Artificial Intelligence",
    type: "website",
  },
  robots: { index: true, follow: true },
  creator: "Dane Madsen",
  authors: {
    name: "Dane Madsen",
    url: "https://www.linkedin.com/in/dane-leonard-madsen/"
  },
  other: {
    "google-adsense-account": "ca-pub-9118075995980578"
  }
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <head>
        <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
        <Script async strategy="beforeInteractive" src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-9118075995980578" crossOrigin="anonymous"></Script>
      </head>
      <body className={`${geistSans.variable} ${spaceMono.variable}`}>
        <header>
            <div id='logo-group'>
                <Link href="/">
                  <Image src="/favicon.svg" alt="logo" width={40} height={40} />
                </Link>
                <h1>
                  <span id="title-full">Mobile Artificial Intelligence</span>
                  <span id="title-short">Mobile AI</span>
                </h1>
            </div>
            <div id='link-group'>
                <Link href="https://github.com/orgs/Mobile-Artificial-Intelligence/repositories">Github</Link>
                <Link href="/privacy">Privacy Policy</Link>
            </div>
        </header>
        {children}
      </body>
    </html>
  );
}
