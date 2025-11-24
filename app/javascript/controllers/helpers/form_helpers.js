export class FormHelpers {
  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ''
  }
}