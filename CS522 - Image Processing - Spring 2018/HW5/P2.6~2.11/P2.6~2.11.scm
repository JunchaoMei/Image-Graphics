;;;[P2.6]
;;helpers
(define shift
  (lambda(new old i n);i=2
    (cond ((= i n) (printf ""))
	  (else
	   (begin
	     (vector-set! new i (vector-ref old (- i 2)))
	     (shift new old (+ i 1) n))))))
(define shift2
  (lambda(old)
    (define n (vector-length old))
    (define new (make-vector n))
    (vector-set! new 0 (vector-ref old (- n 2)))
    (vector-set! new 1 (vector-ref old (- n 1)))
    (shift new old 2 n) new))
(define hi
  (lambda(h i)
    (cond ((= i 0) h)
	  (else (shift2 (hi h (- i 1)))))))
(define db4high
  (lambda(db4 h1 imax);imax=127
    (cond ((= imax -1) (printf "end"))
	  (else
	   (begin
	     (vector-set! db4 imax (hi h1 imax))
	     (db4high db4 h1 (- imax 1)))))))
(define db4low
  (lambda(db4 h0 imax dim);imax=127
    (cond ((= imax -1) (printf "end"))
	  (else
	   (begin
	     (vector-set! db4 (+ imax (/ dim 2)) (hi h0 imax))
	     (db4low db4 h0 (- imax 1) dim))))))
(define db4-col
  (lambda(db4im im)
    (matrix-product db4im im)))
(define db4-row
  (lambda(db4im im)
    (matrix-product im (image-transpose db4im))))
(define db4dim
  (lambda(im level)
    (/ (image-rows im) (expt 2 (- level 1)))))
(define db4
  (lambda(dim)
    (define result (make-vector dim))
    (define h1 (make-vector dim))
    (vector-set! h1 0 c)
    (vector-set! h1 1 d)
    (vector-set! h1 (- dim 2) a)
    (vector-set! h1 (- dim 1) b)
    (define h0 (make-vector dim))
    (vector-set! h0 0 b)
    (vector-set! h0 1 (- a))
    (vector-set! h0 (- dim 2) d)
    (vector-set! h0 (- dim 1) (- c))
    (db4high result h1 (- (/ dim 2) 1))
    (db4low result h0 (- (/ dim 2) 1) dim)
    (array->image result)))
;;variables
(define zebra (read-image "zebra.pgm"))
(define a (/ (- 1 (sqrt 3)) (* 4 (sqrt 2))))
(define b (/ (+ -3 (sqrt 3)) (* 4 (sqrt 2))))
(define c (/ (+ 3 (sqrt 3)) (* 4 (sqrt 2))))
(define d (/ (- -1 (sqrt 3)) (* 4 (sqrt 2))))
(define db4all (make-vector 7))
(vector-set! db4all 1 (db4 (image-rows zebra)))
(vector-set! db4all 2 (db4 (db4dim zebra 2)))
(vector-set! db4all 3 (db4 (db4dim zebra 3)))
(vector-set! db4all 4 (db4 (db4dim zebra 4)))
(vector-set! db4all 5 (db4 (db4dim zebra 5)))
(vector-set! db4all 6 (db4 (db4dim zebra 6)))
;level1
(define zebra1 (db4-row (vector-ref db4all 1) (db4-col (vector-ref db4all 1) zebra)))
(define zebra12 (image-crop zebra1 0 0 (db4dim zebra 2) (db4dim zebra 2)))
(define zebra13 (image-crop zebra1 (db4dim zebra 2) 0 (db4dim zebra 2) (db4dim zebra 2)))
(define zebra14 (image-crop zebra1 0 (db4dim zebra 2) (db4dim zebra 2) (db4dim zebra 2)))
(define zebra11 (image-crop zebra1 (db4dim zebra 2) (db4dim zebra 2) (db4dim zebra 2) (db4dim zebra 2)))
;level2
(define zebra2 (db4-row (vector-ref db4all 2) (db4-col (vector-ref db4all 2) zebra11)))
(define zebra22 (image-crop zebra2 0 0 (db4dim zebra 3) (db4dim zebra 3)))
(define zebra23 (image-crop zebra2 (db4dim zebra 3) 0 (db4dim zebra 3) (db4dim zebra 3)))
(define zebra24 (image-crop zebra2 0 (db4dim zebra 3) (db4dim zebra 3) (db4dim zebra 3)))
(define zebra21 (image-crop zebra2 (db4dim zebra 3) (db4dim zebra 3) (db4dim zebra 3) (db4dim zebra 3)))
;recursion
(define imagel
  (lambda(im l)
    (cond ((= l 1) (db4-row (vector-ref db4all 1) (db4-col (vector-ref db4all 1) im)))
	  (else (db4-row (vector-ref db4all l) (db4-col (vector-ref db4all l) (imageli im (- l 1) 1)))))))
(define imageli
  (lambda(im l i)
    (cond ((= i 1) (image-crop (imagel im l) (db4dim im (+ l 1)) (db4dim im (+ l 1)) (db4dim im (+ l 1)) (db4dim im (+ l 1))))
	  ((= i 2) (image-crop (imagel im l) 0 0 (db4dim im (+ l 1)) (db4dim im (+ l 1))))
	  ((= i 3) (image-crop (imagel im l) (db4dim im (+ l 1)) 0 (db4dim im (+ l 1)) (db4dim im (+ l 1))))
	  ((= i 4) (image-crop (imagel im l) 0 (db4dim im (+ l 1)) (db4dim im (+ l 1)) (db4dim im (+ l 1)))))))
(define recur (make-vector 5))
;;function
(define daubechies4
  (lambda(im l k);k=max level
    (cond ((= l k)
	   (begin
	     (define recurk (make-vector 5))
	     (vector-set! recurk 2 (imageli im l 2))
	     (vector-set! recurk 3 (imageli im l 3))
	     (vector-set! recurk 4 (imageli im l 4))
	     (vector-set! recurk 1 (imageli im l 1))
	     recurk))
	  (else
	   (begin
	     (define recurl (make-vector 5))
	     (vector-set! recurl 2 (imageli im l 2))
	     (vector-set! recurl 3 (imageli im l 3))
	     (vector-set! recurl 4 (imageli im l 4))
	     (vector-set! recurl 1 (daubechies4 im (+ l 1) k))
	     recurl)))))
;;test
(define zebra-db4-vector (daubechies4 zebra 1 6))


;;;[P2.7]
;;helpers
(define db4-inv-col
  (lambda(db4im im1)
    (matrix-product (image-transpose db4im) im1)))
(define db4-inv-row
  (lambda(db4im im1)
    (matrix-product im1 db4im)))
(define findim
  (lambda(db4vec l i)
    (cond ((= l 1) (vector-ref db4vec i))
	  (else (vector-ref (findim db4vec (- l 1) 1) i)))))
;;function
(define inverse-daubechies4
  (lambda(db4vec l k);k=max level
    (cond ((= l k) (db4-inv-row (vector-ref db4all l) (db4-inv-col (vector-ref db4all l) (top-to-bottom (left-to-right (findim db4vec l 2) (findim db4vec l 4)) (left-to-right (findim db4vec l 3) (findim db4vec l 1))))))
	  (else (db4-inv-row (vector-ref db4all l) (db4-inv-col (vector-ref db4all l) (top-to-bottom (left-to-right (findim db4vec l 2) (findim db4vec l 4)) (left-to-right (findim db4vec l 3) (inverse-daubechies4 db4vec (+ l 1) k)))))))))
;;test
(define zebra-reconstructed (inverse-daubechies4 zebra-db4-vector 1 6))
(write-image zebra-reconstructed "zebra-reconstructed.pgm")


;;;[P2.8]
;;helpers
(define display
  (lambda(db4vec l k);k=max level
    (cond ((= l k) (top-to-bottom (left-to-right (findim db4vec l 1) (findim db4vec l 2)) (left-to-right (findim db4vec l 3) (findim db4vec l 4))))
	  (else (top-to-bottom (left-to-right (display db4vec (+ l 1) k) (findim db4vec l 2)) (left-to-right (findim db4vec l 3) (findim db4vec l 4)))))))
;;function
(define display-wavelet-transform
  (lambda(db4vec k)
    (image-map normalize (display db4vec 1 k))))
;;test
(define zebra-db4 (display-wavelet-transform zebra-db4-vector 6))
(write-image zebra-db4 "zebra-db4.pgm")


;;;[P2.9~2.11]
;;helpers
(define thresh
  (lambda(im x)
    (make-image (image-rows im) (image-cols im)
		(lambda(i j)
		  (if (< (image-ref im i j) x) 0
		      (image-ref im i j))))))
(define db4vecthresh
  (lambda(db4vec l k x)
    (cond ((= l k)
	   (begin
	     (define recurk (make-vector 5))
	     (vector-set! recurk 2 (thresh (findim db4vec l 2) x))
	     (vector-set! recurk 3 (thresh (findim db4vec l 3) x))
	     (vector-set! recurk 4 (thresh (findim db4vec l 4) x))
	     (vector-set! recurk 1 (thresh (findim db4vec l 1) x))
	     recurk))
	  (else
	   (begin
	     (define recurl (make-vector 5))
	     (vector-set! recurl 2 (thresh (findim db4vec l 2) x))
	     (vector-set! recurl 3 (thresh (findim db4vec l 3) x))
	     (vector-set! recurl 4 (thresh (findim db4vec l 4) x))
	     (vector-set! recurl 1 (db4vecthresh db4vec (+ l 1) k x))
	     recurl)))))
;;variables
(define nl (read-color-image "noisylena.ppm"))
(define nlhsi (rgb->hsi (color-image-red nl) (color-image-green nl) (color-image-blue nl)))
(define nlh (car nlhsi))
(define nls (cadr nlhsi))
(define nli (caddr nlhsi))
;S
(define nlsdb4vec (daubechies4 nls 1 6))
(define nlsdb4vecthresh (db4vecthresh nlsdb4vec 1 6 10))
(define nlsrecon (inverse-daubechies4 nlsdb4vecthresh 1 6))
;I
(define nlidb4vec (daubechies4 nli 1 6))
(define nlidb4vecthresh (db4vecthresh nlidb4vec 1 6 10))
(define nlirecon (inverse-daubechies4 nlidb4vecthresh 1 6))
;return
(hsi->color-image nlh nlsrecon nlirecon)
;;function
(define denoise-color-image
  (lambda(cim k xs xi)
    (define hsi (rgb->hsi (color-image-red cim) (color-image-green cim) (color-image-blue cim)))
    (hsi->color-image (car hsi) (inverse-daubechies4 (db4vecthresh (daubechies4 (cadr hsi) 1 k) 1 k xs) 1 k) (inverse-daubechies4 (db4vecthresh (daubechies4 (caddr hsi) 1 k) 1 k xi) 1 k))))
;;test
(define nl-denoise20 (denoise-color-image nl 6 20 20))
(write-color-image nl-denoise20 "nl-denoise20.ppm")
(define nl-denoise100 (denoise-color-image nl 6 100 100))
(write-color-image nl-denoise100 "nl-denoise100.ppm")
