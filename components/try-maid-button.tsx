"use client"; // required for onClick in app directory
import style from './try-maid-button.module.css';

export default function TryMaidButton() {
    return (
        <button className={style.maidButton} onClick={() => window.location.href = "https://maid-app.com"} >
          Try Maid Online Now
        </button>
    );
}