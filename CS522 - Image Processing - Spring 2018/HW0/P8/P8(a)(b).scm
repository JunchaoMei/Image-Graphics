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

;;(a)right-split

;;if not using function
(define left (reduce-rows fg))
;n=1
(define quarter1 (reduce fg));(cond (pred1 val1) (else valN))
(define right1 (top-to-bottom quarter1 quarter1))
(define rs1 (left-to-right left right1))
;n=2
(define quarter2 (reduce rs1))
(define right2 (top-to-bottom quarter2 quarter2))
(define rs2 (left-to-right left right2))
;n=3
(define quarter3 (reduce rs2))
(define right3 (top-to-bottom quarter3 quarter3))
(define rs3 (left-to-right left right3))

;;function {right-split}
(define left (lambda(im) (reduce-rows im)))
(define quarter (lambda(im n) (cond ((= n 1) (reduce im)) (else (reduce (right-split im (- n 1)))))))
(define right (lambda(im n) (top-to-bottom (quarter im n) (quarter im n))))
(define right-split (lambda(im n) (left-to-right (left im) (right im n))))
;test function
(define rs5 (right-split fg 5))
;use function
(write-image rs5 "rs5.ppm")


;;(b)bottom-split

;;if not using function
(define up (reduce-cols fg))
;n=1
(define quarter1 (reduce fg))
(define down1 (left-to-right quarter1 quarter1))
(define bs1 (top-to-bottom up down1))
;n=2
(define quarter2 (reduce bs1))
(define down2 (left-to-right quarter2 quarter2))
(define bs2 (top-to-bottom up down2))
;n=3
(define quarter3 (reduce bs2))
(define down3 (left-to-right quarter3 quarter3))
(define bs3 (top-to-bottom up down3))

;;function bottom-split
(define up (lambda(im) (reduce-cols im)))
(define quarter (lambda(im n) (cond ((= n 1) (reduce im)) (else (reduce (bottom-split im (- n 1)))))))
(define down (lambda(im n) (left-to-right (quarter im n) (quarter im n))))
(define bottom-split (lambda(im n) (top-to-bottom (up im) (down im n))))
;test function
(define bs5 (bottom-split fg 5))
;use function
(write-image bs5 "bs5.ppm")