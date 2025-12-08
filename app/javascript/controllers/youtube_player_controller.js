import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame", "videoList"]
  static values = {
    videoId: String,
    currentVideo: String
  }

  connect() {
    this.loadYouTubeAPI()
  }

  loadYouTubeAPI() {
    if (window.YT) {
      this.initPlayer()
    } else {
      const tag = document.createElement('script')
      tag.src = "https://www.youtube.com/iframe_api"
      const firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

      window.onYouTubeIframeAPIReady = () => {
        this.initPlayer()
      }
    }
  }

  initPlayer() {
    if (!this.hasFrameTarget) return

    this.player = new YT.Player(this.frameTarget, {
      height: '360',
      width: '100%',
      videoId: this.currentVideoValue || this.videoIdValue,
      playerVars: {
        'playsinline': 1,
        'rel': 0
      },
      events: {
        'onReady': this.onPlayerReady.bind(this)
      }
    })
  }

  onPlayerReady(event) {
    console.log('YouTube Player ready')
  }

  playVideo(event) {
    event.preventDefault()
    const videoId = event.currentTarget.dataset.videoId

    if (this.player) {
      this.player.loadVideoById(videoId)
      this.currentVideoValue = videoId

      // Update active state
      this.videoListTarget.querySelectorAll('.video-item').forEach(item => {
        item.classList.remove('active')
      })
      event.currentTarget.classList.add('active')
    }
  }

  disconnect() {
    if (this.player) {
      this.player.destroy()
    }
  }
}
