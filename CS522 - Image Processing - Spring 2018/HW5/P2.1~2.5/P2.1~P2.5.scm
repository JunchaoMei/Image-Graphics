;;;[P2.1]
;;varibales
(define fg (read-image "frog.pgm"))
(define vec1 (vector-map / #(1 5 8 5 1) #(20 20 20 20 20)))
;;function
(define reduce
  (lambda(im v1)
    (downsample (convolve-cols (convolve-rows im v1) v1))))
;;test
(define fg-reduced (reduce fg vec1))
(write-image fg-reduced "fg-reduced.pgm")


;;;[P2.2]
;;variables
(define vec2 (vector-map / #(1 5 8 5 1) #(10 10 10 10 10)))
;;function
(define project
  (lambda(im v2)
    (convolve-cols (convolve-rows (upsample im) v2) v2)))
;;test
(define fg-reduced-projected (project fg-reduced vec2))
(write-image fg-reduced-projected "fg-reduced-projected.pgm")


;;;[P2.3]
;;varibles
(define V0 fg)
(define V1 fg-reduced)
(define L1 (- V0 fg-reduced-projected))
(define V2 (reduce V1 vec1))
(define L2 (- V1 (project V2 vec2)))
;;function
(define Vi
  (lambda(im i v1)
    (cond ((= i 0) im)
	  (else (reduce (Vi im (- i 1) v1) v1)))))
(define Li
  (lambda(im i v1 v2)
    (- (Vi im (- i 1) v1) (project (Vi im i v1) v2))))
(define setL
  (lambda(L im i v1 v2)
    (cond ((= i 0) (printf "complete"))
	  (else
	   (begin (vector-set! L i (Li im i v1 v2))
		  (setL L im (- i 1) v1 v2))))))
(define laplacian-pyramid
  (lambda(im k v1 v2)
    (define LL (make-vector (+ k 1)))
    (setL LL im k v1 v2) LL))
;;test
(define fg-lapy (laplacian-pyramid fg 4 vec1 vec2))
(write-image (vector-ref fg-lapy 1) "fg-L1.pgm")
(write-image (vector-ref fg-lapy 2) "fg-L2.pgm")
(write-image (vector-ref fg-lapy 3) "fg-L3.pgm")
(write-image (vector-ref fg-lapy 4) "fg-L4.pgm")
(write-image (Vi fg 1 vec1) "fg-V1.pgm")
(write-image (Vi fg 2 vec1) "fg-V2.pgm")
(write-image (Vi fg 3 vec1) "fg-V3.pgm")
(write-image (Vi fg 4 vec1) "fg-V4.pgm")


;;;[P2.4]
;;variables
(define V4 (Vi fg 4 vec1))
(define V3 (+ (project V4 vec2) (vector-ref fg-lapy 4)))
(define V2 (+ (project V3 vec2) (vector-ref fg-lapy 3)))
;;function
(define inverse-lapy
  (lambda(lapy thumbnail i k v2)
    (cond ((= i k) thumbnail)
	  (else (+ (project (inverse-lapy lapy thumbnail (+ i 1) k v2) v2) (vector-ref lapy (+ i 1)))))))
(define inverse-laplacian-pyramid
  (lambda(lapy thumbnail v2)
    (inverse-lapy lapy thumbnail 0 (- (vector-length lapy) 1) v2)))
;;test
(define fg-reconstructed (inverse-laplacian-pyramid fg-lapy V4 vec2))
(write-image fg-reconstructed "fg-reconstructed.pgm")


;;;[P2.5]
;;variables
(define pdlist (make-vector (+ 4 1)))
;;function
(define padding
  (lambda(Li i)
    (image-pad Li (* (image-rows Li) (expt 2 (- i 1))) (image-cols Li))))
(define padall
  (lambda(pd lapy k)
    (cond ((= k 1) (vector-set! pd 1 (vector-ref lapy 1)))
	  (else
	   (begin
	     (vector-set! pd k (padding (vector-ref lapy k) k))
	     (padall pd lapy (- k 1)))))))
(define padded
  (lambda(lapy)
    (define k (- (vector-length lapy) 1))
    (define pd (make-vector (+ k 1)))
    (padall pd lapy k) pd))
(define combine
  (lambda(padded i k)
    (cond ((= i k) (vector-ref padded k))
	  (else (left-to-right (vector-ref padded i) (combine padded (+ i 1) k))))))
(define normalize
  (lambda(p)
    (+ 128 (* (/ 127 255) p))))
(define display-laplacian-pyramid
  (lambda(lapy)
    (define k (- (vector-length lapy) 1))
    (define padd (padded lapy))
    (image-map normalize (combine padd 1 k))))
;;test
(define fg-lapy-display (display-laplacian-pyramid fg-lapy))
(write-image fg-lapy-display "fg-lapy-display.pgm")
    
