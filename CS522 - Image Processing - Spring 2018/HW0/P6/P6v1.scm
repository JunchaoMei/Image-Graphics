;load image
(define mec (read-color-image "mec.ppm"))
mec

;function color-image-crop
(define color-image-crop
	(lambda(image i0 j0 a b)
		(define cropped (image-crop mec i0 j0 a b))
		cropped
	)
)

;test function
(color-image-crop mec 50 50 200 200)