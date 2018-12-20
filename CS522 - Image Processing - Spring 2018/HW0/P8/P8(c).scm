;load image
(define fg (read-image "fg.pgm"))

;; reduce in horizontal dimension without aliasing
(define (reduce-rows x)
	(downsample-rows
		(convolve-rows x #(0.05 0.25 0.4 0.25 0.05))))
;; reduce in vertical dimension without aliasing
(define (reduce-cols x)
	(downsample-cols
		(convolve-cols x #(0.05 0.25 0.4 0.25 0.05))))
;; reduce in both dimensions without aliasing
(define (reduce x)
	(reduce-rows (reduce-cols x)))

;;(c)corner-split

;;if not using function
(define upleft (reduce fg))
;n=1 (initial definition)
(define downright1 upleft)
(define downleft_half1 (reduce-rows upleft))
(define downleft1 (left-to-right downleft_half1 downleft_half1))
(define down1 (left-to-right downleft1 downright1))
(define upright_half1 (reduce-cols upleft))
(define upright1 (top-to-bottom upright_half1 upright_half1))
(define up1 (left-to-right upleft upright1))
(define cs1 (top-to-bottom up1 down1))
;n=2 (n>=2: recursive definition)
(define downright2 (reduce cs1))
(define downleft_half2 (image-crop downright2 0 0 280 140))
(define downleft2 (left-to-right downleft_half2 downleft_half2))
(define down2 (left-to-right downleft2 downright2))
(define upright_half2 (image-crop downright2 0 0 140 280))
(define upright2 (top-to-bottom upright_half2 upright_half2))
(define up2 (left-to-right upleft upright2))
(define cs2 (top-to-bottom up2 down2))
;n=3
(define downright3 (reduce cs2))
(define downleft_half3 (image-crop downright3 0 0 280 140))
(define downleft3 (left-to-right downleft_half3 downleft_half3))
(define down3 (left-to-right downleft3 downright3))
(define upright_half3 (image-crop downright3 0 0 140 280))
(define upright3 (top-to-bottom upright_half3 upright_half3))
(define up3 (left-to-right upleft upright3))
(define cs3 (top-to-bottom up3 down3))

;;function corner-split
(define len (lambda(im) (image-rows im)))
(define upleft (lambda(im) (reduce fg)))
(define downright (lambda(im n) (cond ((= n 1) (upleft im)) (else (reduce (corner-split im (- n 1)))))))
(define downleft_half (lambda(im n) (cond ((= n 1) (reduce-rows (upleft im))) (else (image-crop (downright im n) 0 0 (/ (len im) 2) (/ (len im) 4)))))) 
(define downleft (lambda(im n) (left-to-right (downleft_half im n) (downleft_half im n))))
(define down (lambda(im n) (left-to-right (downleft im n) (downright im n))))
(define upright_half (lambda (im n) (cond ((= n 1) (reduce-cols (upleft im))) (else (image-crop (downright im n) 0 0 (/ (len im) 4) (/ (len im) 2))))))
(define upright (lambda (im n) (top-to-bottom (upright_half im n) (upright_half im n))))
(define up (lambda (im n) (left-to-right (upleft im) (upright im n))))
(define corner-split (lambda(im n) (top-to-bottom (up im n) (down im n))))
;test function
(define cs2 (corner-split fg 2))
;use function
(write-image cs2 "cs2.ppm")
