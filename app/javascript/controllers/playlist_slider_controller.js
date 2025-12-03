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
    // On vérifie qu'on n'est pas déjà au début
    if (this.currentIndexValue > 0) {
      // On décrémente l'index (on recule d'une page)
      this.currentIndexValue--

      // On met à jour l'affichage
      this.updateSlider()
    }
  }

  // Méthode appelée quand on clique sur le bouton "suivant"
  // L'action sera : data-action="click->playlist-slider#next"
  next() {
    // On calcule le nombre maximum de pages
    // Math.ceil arrondit au supérieur (ex: 7 items / 3 par page = 3 pages)
    const maxIndex = Math.ceil(this.totalItems / this.itemsPerPageValue) - 1

    // On vérifie qu'on n'est pas déjà à la fin
    if (this.currentIndexValue < maxIndex) {
      // On incrémente l'index (on avance d'une page)
      this.currentIndexValue++

      // On met à jour l'affichage
      this.updateSlider()
    }
  }

  // Méthode qui met à jour l'affichage du slider
  updateSlider() {
    // DÉPLACEMENT DU SLIDER
    // On calcule le décalage en pourcentage
    // Ex: si on est à la page 1 et qu'on affiche 3 items par page
    // offset = 1 * (100 / 3) = 33.33%
    const offset = this.currentIndexValue * (100 / this.itemsPerPageValue)

    // On applique la transformation CSS pour déplacer le slider
    this.sliderTarget.style.transform = `translateX(-${offset}%)`

    // GESTION DU BOUTON PRÉCÉDENT
    if (this.currentIndexValue === 0) {
      // Si on est au début, on désactive visuellement le bouton
      this.prevBtnTarget.style.opacity = '0.3'
      this.prevBtnTarget.style.pointerEvents = 'none'  // Empêche les clics
    } else {
      // Sinon, on le rend actif
      this.prevBtnTarget.style.opacity = '1'
      this.prevBtnTarget.style.pointerEvents = 'auto'
    }

    // GESTION DU BOUTON SUIVANT
    const maxIndex = Math.ceil(this.totalItems / this.itemsPerPageValue) - 1

    if (this.currentIndexValue >= maxIndex) {
      // Si on est à la fin, on désactive visuellement le bouton
      this.nextBtnTarget.style.opacity = '0.3'
      this.nextBtnTarget.style.pointerEvents = 'none'
    } else {
      // Sinon, on le rend actif
      this.nextBtnTarget.style.opacity = '1'
      this.nextBtnTarget.style.pointerEvents = 'auto'
    }
  }
}
