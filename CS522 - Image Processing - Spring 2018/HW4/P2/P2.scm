;;;[P2.1]
;;variables
(define fg (read-image "frog.pgm"))
;;function
(define ilp
  (lambda(width)
    (lambda(i j)
      (cond ((< (+ (* i i) (* j j)) (* width width)) 1)
	  (else 0)))))
(define ideal-lowpass
  (lambda(n width)
    (make-filter n n (ilp width))))
;;test
(define ilp-256-16 (ideal-lowpass 256 16))
(write-image ilp-256-16 "ilp-256-16.pgm")
(write-image (real-part (ifft (* (fft fg) ilp-256-16))) "fg-ilp.pgm")


;;;[P2.2]
;;function
(define gaussian1
  (lambda(variance)
    (lambda(i j)
      (let* ((r2 (+ (* i i) (* j j)))
	     (x (/ r2 2 pi variance)))
	(exp (- x))))))
(define gaussian-lowpass
  (lambda(n variance)
    (make-filter n n (gaussian1 variance))))
;;test
(define glp-256-32 (gaussian-lowpass 256 32))
(write-image glp-256-32 "glp-256-32.pgm")
(write-image (real-part (ifft (* (fft fg) glp-256-32))) "fg-glp.pgm")


;;;[P2.3]
;;function
(define ibp
  (lambda(center width)
    (lambda(i j)
      (let* ((r (- center (/ width 2)))
	     (R (+ center (/ width 2))))
	(cond ((and (> (+ (* i i) (* j j)) (* r r)) (< (+ (* i i) (* j j)) (* R R))) 1)
	      (else 0))))))
(define ideal-bandpass
  (lambda(n center width)
    (make-filter n n (ibp center width))))
;;test
(define ibp-256-32-16 (ideal-bandpass 256 32 16))
(write-image ibp-256-32-16 "ibp-256-32-16.pgm")
(write-image (real-part (ifft (* (fft fg) ibp-256-32-16))) "fg-ibp.pgm")


;;;[P2.4]
;;function
(define gaussian2
  (lambda(center variance)
    (lambda(i j)
      (let* ((dist2 (abs (- (+ (* i i) (* j j)) (* center center))))
	     (x (/ dist2 2 pi variance)))
	(exp (- x))))))
(define gaussian-bandpass
  (lambda(n center variance)
    (make-filter n n (gaussian2 center variance))))
;;test
(define gbp-256-32-32 (gaussian-bandpass 256 32 32))
(write-image gbp-256-32-32 "gbp-256-32-32.pgm")
(write-image (real-part (ifft (* (fft fg) gbp-256-32-32))) "fg-gbp.pgm")
