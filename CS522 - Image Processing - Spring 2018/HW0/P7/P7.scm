;;load 2 images
(define cim0 (read-color-image "Lisa1.ppm"))
(define cim1 (read-color-image "Lisa2.ppm"))
cim0
cim1

;;function merge
(define merge
  (lambda(im1,im2)
    (hsi->color-image (car (color-image->hsi cim1)) (cadr (color-image->hsi cim1)) (caddr (color-image->hsi cim0)))))
;;test function
(define Lisa-daVinci (merge cim0 cim1))
;;use function
(write-color-image Lisa-daVinci "Lisa-daVinci.ppm")


;;if not using function
;;get h/s/i
(define hsi0 (color-image->hsi cim0))
(define hsi1 (color-image->hsi cim1))
(define intensity (caddr hsi0))
(define hue (car hsi1))
(define saturation (cadr hsi1))
; get merged image
(define cim (hsi->color-image hue saturation intensity))
cim
