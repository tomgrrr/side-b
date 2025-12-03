import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collection"
export default class extends Controller {
  static targets = ["slider"]

  connect() {
    this.currentIndex = 0
    this.visibleCount = 2
    this.links = this.sliderTarget.querySelectorAll(".slider-link")
    this.totalCount = this.links.length

    this.startAutoplay()
    this.updateSlider()
  }

  disconnect() {
    clearInterval(this.interval)
  }

  startAutoplay() {
    this.interval = setInterval(() => {
      this.nextSlide()
    }, 10000) // toutes les 10 secondes
  }

  nextSlide() {
    this.currentIndex += this.visibleCount
    if (this.currentIndex >= this.totalCount) this.currentIndex = 0
    this.updateSlider()
  }

  prevSlide() {
    this.currentIndex -= this.visibleCount
    if (this.currentIndex < 0) this.currentIndex = this.totalCount - this.visibleCount
    this.updateSlider()
  }

  updateSlider() {
    const offset = -(this.currentIndex * (100 / this.visibleCount))
    this.sliderTarget.style.transform = `translateX(${offset}%)`
  }
}
