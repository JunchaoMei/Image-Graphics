;helpers
(define rad->degree (lambda(rad) (* rad 180 (/ 1 pi))))
(define degree->rad (lambda(degree) (* degree pi (/ 1 180))))
(define round ;(cond (pred1 val1) (else valN))
  (lambda (x)
    (cond ((< (- x (floor x)) 0.5) (floor x)) (else (+ 1 (floor x))))))
(define dist
  (lambda(i j a b)
    (sqrt (+ (expt (- i a) 2) (expt (- j b) 2)))))
(define theta_raw
  (lambda(i j a b)
    (atan (/ (- a i) (+ (- j b) 0.00000000000001)))))
(define arctan
  (lambda(atanget i j a b)
    (cond ((< j b) (+ atanget (degree->rad 180)))
	  ((and (>= j b) (> i a)) (+ atanget (degree->rad 360)))
	  (else atanget))))
(define theta
  (lambda(i j a b)
    (arctan (theta_raw i j a b) i j a b)))
(define THETA
  (lambda(theta phi)
    (+ theta (degree->rad phi))))
(define I_raw
  (lambda(R THETA a)
    (round (- a (* R (sin THETA))))))
(define J_raw
  (lambda(R THETA b)
    (round (+ (* R (cos THETA)) b))))
(define I
  (lambda(i j a b phi)
    (I_raw (dist i j a b) (THETA (theta i j a b) phi) a)))
(define J
  (lambda(i j a b phi)
    (J_raw (dist i j a b) (THETA (theta i j a b) phi) b)))
(define fun (lambda(i j) (display (string-append "(" (number->string i) "," (number->string j) ")"))))
(define loop
  (lambda(i j imin jmin imax jmax)
    (if (<= i imax)
	(begin
	  (if (<= j jmax)
	      (begin
		(fun i j)
		(loop i (+ j 1) imin jmin imax jmax))
	      (loop (+ i 1) jmin imin jmin imax jmax))))))
(define Igot
  (lambda(im i j phi)
    (I i j (/ (- (image-rows im) 1) 2) (/ (- (image-cols im) 1) 2) phi)))
(define Jgot
  (lambda(im i j phi)
    (J i j (/ (- (image-rows im) 1) 2) (/ (- (image-cols im) 1) 2) phi)))
(define within
  (lambda(im Igot Jgot)
    (and (>= Igot 0) (< Igot (image-rows im)) (>= Jgot 0) (< Jgot (image-cols im)))))
(define rotateij
  (lambda(im blk i j phi)
    (if (within im (Igot im i j phi) (Jgot im i j phi))
	(image-set! blk (Igot im i j phi) (Jgot im i j phi) (image-ref im i j)))))
(define rotateloop
  (lambda(i j imin jmin imax jmax im blk phi)
    (if (<= i imax)
	(begin
	  (if (<= j jmax)
	      (begin
		(rotateij im blk i j phi)
		(rotateloop i (+ j 1) imin jmin imax jmax im blk phi))
	      (rotateloop (+ i 1) jmin imin jmin imax jmax im blk phi))))))
;variables
(define fg (read-image "frog.pgm"))
(define rowmax (- (image-rows fg) 1))
(define colmax (- (image-cols fg) 1))
(define a (/ rowmax 2))
(define b (/ colmax 2))
(define black (make-image (image-rows fg) (image-cols fg)))

;;function
(define rotate-image
  (lambda(im phi)
    (define blk (make-image (image-rows im) (image-cols im)))
    (rotateloop 0 0 0 0 (- (image-rows im) 1) (- (image-cols im) 1) im blk phi) blk))
;test function
(write-image (rotate-image fg 35) "frog35.pgm")
(write-image (rotate-image fg 90) "frog90.pgm")
(write-image (rotate-image fg 116) "frog116.pgm")
(write-image (rotate-image fg 180) "frog180.pgm")
(write-image (rotate-image fg 233) "frog233.pgm")
(write-image (rotate-image fg 270) "frog270.pgm")
(write-image (rotate-image fg 301) "frog301.pgm")
