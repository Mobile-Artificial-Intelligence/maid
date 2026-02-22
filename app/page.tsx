import Image from "next/image";
import Carousel from "@/components/carousel";
import styles from "@/app/page.module.css";

export default function Home() {
  return (
    <div>
      <section className={styles.titleSection} >
          <h1>Mobile + AI</h1>
          <h2>Artificial Intelligence on the edge</h2>
          <h2>Brisbane, Australia</h2>
      </section>
      <section className={styles.maidSection} >
          <div className={styles.maidText} >
              <h1>Mobile Artificial Intelligence Distribution</h1>
              <p>
                  The Mobile Artifical Intelligence Distribution (MAID) project is a research initiative 
                  focused on the development and deployment of artificial intelligence (AI) systems on 
                  mobile devices. 
              </p>
              <p>
                  The goal of MAID is to create a frontend for AI that is private, secure, 
                  and efficient, allowing users to leverage the power of AI without compromising their
                  personal data or privacy.
              </p>
          </div>
          <div className={styles.maidText} >
              <h2>First of its kind</h2>
              <p>
                  In development since 2022, Maid is the first project to allow users to conveniently chat with 
                  large language models locally on their mobile devices without a internet connection. 
              </p>
          </div>
          <div className={styles.maidLists} >
              <div className={styles.maidText} >
                  <h2>Supported Ecosystems</h2>
                  <ul>
                      <li>Llama.cpp</li>
                      <li>Ollama</li>
                      <li>OpenAI</li>
                      <li>Mistral</li>
                      <li>Anthropic</li>
                      <li>DeepSeek</li>
                  </ul>
              </div>
          </div>
          <div className={styles.maidLinks} >
              <a href="https://play.google.com/store/apps/details?id=com.danemadsen.maid&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1">
                <Image 
                  src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
                  alt="Get it on Google Play"
                  height={80}
                  width={210} 
                />
              </a>
              <a href="https://www.openapk.net/maid/com.danemadsen.maid/">
                <Image 
                  src="https://www.openapk.net/images/openapk-badge.png"
                  alt="Get it on OpenAPK"
                  height={80}
                  width={210} 
                />
              </a>
              <a href="https://www.androidfreeware.net/download-maid-apk.html">
                <Image 
                  src="https://www.androidfreeware.net/images/androidfreeware-badge.png"
                  alt="Get it on Android Freeware"
                  height={80}
                  width={210} 
                />
              </a>
              <a href="https://github.com/Mobile-Artificial-Intelligence/maid/releases/latest">
                <Image
                  src="https://raw.githubusercontent.com/NeoApplications/Neo-Backup/refs/heads/main/badge_github.png"
                  alt="Get it on GitHub"
                  height={80}
                  width={210} 
                />
              </a>
          </div>
          <Carousel />
      </section>
    </div>
  );
}
