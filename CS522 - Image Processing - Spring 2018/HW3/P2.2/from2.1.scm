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
(define theta
  (lambda(i j a b)
    (arctan (theta_raw i j a b) i j a b)))
