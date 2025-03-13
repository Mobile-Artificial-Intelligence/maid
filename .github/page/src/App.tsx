import { useState } from 'react'
import maidLogoLight from '/logo.svg'
import maidLogoDark from '/logo-dark.svg'
import './App.css'

function App() {
  return (
    <>
      <div>
        <a href="https://github.com/Mobile-Artificial-Intelligence/maid" target="_blank">
          <img src={maidLogoDark} className="logo" alt="Maid logo" />
        </a>
      </div>
      <h1 className='title'>MAID</h1>
    </>
  )
}

export default App
