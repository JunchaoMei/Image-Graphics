;; if not using function
(define height 300)
(define width (* height (/ 4 3)))
(define a (/ height 2))
(define b (/ width 2))
(define r (/ a 2))
(define r2 (* r r))
(define lhs (+ (expt (- 160 a) 2) (expt (- 210 b) 2)))
(define rhs (expt r 2))
(define pre1 (<= lhs rhs))
(define bool (cond (pre1 255) (else 0))) ;;(cond (pred1 val1) (else valN))
;;helper-function
(define japan (lambda(x y) (cond ((<= (+ (expt (- x (/ height 2)) 2) (expt (- y (/ (* height (/ 4 3)) 2)) 2)) (expt (/ (/ height 2) 2) 2)) (+ -0.1i 6)) (else 255))))
;;test
(make-image 300 400 japan)
;;rgb for pure red
(define r (make-image 200 200 (lambda(i j) 255)))
(define g (make-image 200 200 (lambda(i j) 0)))
(define b (make-image 200 200 (lambda(i j) 0)))
(rgb->color-image r g b)
;;r for circle
(define r (make-image 300 400 (lambda(x y) 255)))
(define g (make-image 300 400 (lambda(x y) (cond ((<= (+ (expt (- x (/ height 2)) 2) (expt (- y (/ (* height (/ 4 3)) 2)) 2)) (expt (/ (/ height 2) 2) 2)) 0) (else 255)))))
(define b (make-image 300 400 (lambda(x y) (cond ((<= (+ (expt (- x (/ height 2)) 2) (expt (- y (/ (* height (/ 4 3)) 2)) 2)) (expt (/ (/ height 2) 2) 2)) 0) (else 255)))))
(rgb->color-image r g b)


;;function {flag-japan}
(define r (lambda(height) (make-image height (* height (/ 4 3)) (lambda(x y) 255))))
(define g (lambda(height) (make-image height (* height (/ 4 3)) (lambda(x y) (cond ((<= (+ (expt (- x (/ height 2)) 2) (expt (- y (/ (* height (/ 4 3)) 2)) 2)) (expt (/ (/ height 2) 2) 2)) 0) (else 255))))))
(define flag-japan (lambda(height) (rgb->color-image (r height) (g height) (g height))))
;;test function
(define japan270 (flag-japan 270))
;;use function
(write-color-image japan270 "japan-height-270.ppm") ;; the written image is not the image generated!!!
