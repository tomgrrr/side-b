import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="playlist-slider"
export default class extends Controller {
  static targets = ["slider", "prevBtn", "nextBtn"]

  static values = {
    itemsPerPage: { type: Number, default: 3 },
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    console.log("Playlist slider connecté!")
    this.totalItems = this.sliderTarget.querySelectorAll('.playlist-pill').length
    this.updateSlider()
  }

  previous() {

    if (this.currentIndexValue > 0) {

      this.currentIndexValue--

      this.updateSlider()
    }
  }

  next() {

    const maxIndex = Math.ceil(this.totalItems / this.itemsPerPageValue) - 1

    if (this.currentIndexValue < maxIndex) {

      this.currentIndexValue++

      this.updateSlider()
    }
  }


  updateSlider() {

    const offset = this.currentIndexValue * (100 / this.itemsPerPageValue)

    this.sliderTarget.style.transform = `translateX(-${offset}%)`


    if (this.currentIndexValue === 0) {

      this.prevBtnTarget.style.opacity = '0.3'
      this.prevBtnTarget.style.pointerEvents = 'none'
    } else {

      this.prevBtnTarget.style.opacity = '1'
      this.prevBtnTarget.style.pointerEvents = 'auto'
    }

    const maxIndex = Math.ceil(this.totalItems / this.itemsPerPageValue) - 1

    if (this.currentIndexValue >= maxIndex) {

      this.nextBtnTarget.style.opacity = '0.3'
      this.nextBtnTarget.style.pointerEvents = 'none'
    } else {

      this.nextBtnTarget.style.opacity = '1'
      this.nextBtnTarget.style.pointerEvents = 'auto'
    }
  }
}
