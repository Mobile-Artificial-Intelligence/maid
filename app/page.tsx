import Image from "next/image";
import Carousel from "@/components/carousel";
import TryMaidButton from "@/components/try-maid-button";
import styles from "./page.module.css";

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
          <TryMaidButton />
          <div className={styles.maidText} >
              <h2>First of its kind</h2>
              <p>
                  In development since 2022, Maid is the first project to allow users to conveniently chat with 
                  large language models locally on their mobile devices without a internet connection. 
              </p>
              <p>
                  Maid is also one of the only AI frontends with a broad support of all platforms. Whether you are
                  using a mobile device, a desktop computer, or a web browser, Maid has you covered.
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
                  </ul>
              </div>
              <div className={styles.maidText} >
                  <h2>Supported Platforms</h2>
                  <ul>
                      <li>Android</li>
                      <li>Windows</li>
                      <li>Linux</li>
                      <li>MacOS</li>
                      <li>Web</li>
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
              <a href="https://f-droid.org/packages/com.danemadsen.maid/">
                <Image 
                  src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
                  alt="Get it on F-Droid"
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
      <section className={styles.sdkSection} >
          <h1>llama_sdk</h1>
          <p>
              `llama_sdk` is a dart package created for the Mobile Artificial Intelligence Distribution (MAID) project.
              It provides a simple and efficient way to interact with the the llama.cpp library, 
              allowing developers to integrate advanced AI capabilities into their cross platform flutter applications.
          </p>
          <p>
              The package is designed to be easy to use, with a focus on performance and reliability. 
              It builds llama.cpp from source on all platforms to ensure accountability and transparency.
              This means that developers can trust that the code they are using is secure and free from any malicious
              modifications.
          </p>
          <p>Add `llama_sdk` to your flutter project now by running the following command in your flutter project root:</p>
          <div className={styles.codebox} ><code>flutter pub add llama_sdk</code></div>
      </section>
    </div>
  );
}
