;;;[P1.1]
;;variables
(define rove (read-image "rove.pgm"))
(define rovewm (read-image "watermarked-rove.pgm"))
(define subtra (image-map (lambda(a b) (- a b)) rovewm rove))
(define watermark-12 (real-part (/ (fft rovewm) (fft rove))))
(write-image watermark-12 "watermark-12.pgm")
;;8-bit
(define rove8 (read-image "rove8.pgm"))
(define rovewm8 (read-image "watermarked-rove8.pgm"))
(define watermark-8 (real-part (/ (fft rovewm8) (fft rove8))))
(write-image watermark-8 "watermark-8.pgm")


;;;[P1.2]
;;helpers
(define horizontal-flip
  (lambda(im)
    (make-image (image-rows im) (image-cols im) (lambda(i j) (image-ref im i (- (image-cols im) 1 j))))))
(define vertical-flip
  (lambda(im)
    (make-image (image-rows im) (image-cols im) (lambda(i j) (image-ref im (- (image-rows im) 1 i) j)))))
(define reproduce
  (lambda(im n)
    (cond ((= n 0) im)
	  (else
	   (let* ((bf-1 (reproduce im (- n 1)))
		  (l2r-1 (left-to-right bf-1 (horizontal-flip bf-1))))
	     (top-to-bottom l2r-1 (vertical-flip l2r-1)))))))
;;variables
(define bf0 (read-image "butterfly.pgm"))
(define l2r0 (left-to-right bf0 (horizontal-flip bf0)))
(define bf1 (top-to-bottom l2r0 (vertical-flip l2r0)))
(define l2r1 (left-to-right bf1 (horizontal-flip bf1)))
(define bf2 (top-to-bottom l2r1 (vertical-flip l2r1)))
(define bf-floating (image-map (lambda(a) (+ (* (/ (- a 127.5) 127.5) 0.01) 1)) bf0))
;;function
(define make-watermark
  (lambda(im n ep)
    (image-map (lambda(a) (+ (* (/ (- a 127.5) 127.5) 0.01) 1)) (reproduce im n))))
;;test
(write-image (make-watermark bf0 0 0.01) "bfwm0.pgm")
(write-image (make-watermark bf0 1 0.01) "bfwm1.pgm")
(write-image (make-watermark bf0 2 0.01) "bfwm2.pgm")
(write-image (make-watermark bf0 3 0.01) "bfwm3.pgm")


;;;[P1.3]
;;variables
(define sh (read-image "seahouse.pgm"))
(define bfwm2 (read-image "bfwm2.pgm"))
;;function
(define insert-watermark
  (lambda(im wm)
    (real-part (ifft (* (fft im) wm)))))
;;test
(write-image (insert-watermark sh bfwm2) "sh-bfwm2.pgm")


;;;[P1.4]
;;helpers
(define horizontal-fold
  (lambda(im)
    (make-image (image-rows im) (/ (image-cols im) 2) (lambda(i j) (/ (+ (image-ref im i j) (image-ref im i (- (image-cols im) 1 j))) 2)))))
(define vertical-fold
  (lambda(im)
    (make-image (/ (image-rows im) 2) (image-cols im) (lambda(i j) (/ (+ (image-ref im i j) (image-ref im (- (image-rows im) 1 i) j)) 2)))))
;;variables
(define sh-bfwm2 (read-image "sh-bfwm2.pgm"))
(define bfwm-raw2 (real-part (/ (fft sh-bfwm2) (fft sh))))
(define bfwm-raw1 (horizontal-fold (vertical-fold bfwm-raw2)))
(define bfwm-raw0 (horizontal-fold (vertical-fold bfwm-raw1)))
;;function
(define recover
  (lambda(imwmed im i n)
    (cond ((= i n) (real-part (/ (fft imwmed) (fft im))))
	  (else
	   (horizontal-fold (vertical-fold (recover imwmed im (+ i 1) n)))))))
(define recover-watermark
  (lambda(imwmed im n)
    (recover imwmed im 0 n)))
;;test
(write-image (recover-watermark sh-bfwm2 sh 2) "bfwm-recovered.pgm")
