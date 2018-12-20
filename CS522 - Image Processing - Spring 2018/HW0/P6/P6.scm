(define mec (read-color-image "mec.ppm"))

;;function color-image-crop
(define color-image-crop
  (lambda(image i0 j0 a b)
    (image-crop image i0 j0 a b)))
;;test function
(define cropped (color-image-crop mec 50 50 200 200))
;;use function
(write-color-image cropped "cropped.ppm")
