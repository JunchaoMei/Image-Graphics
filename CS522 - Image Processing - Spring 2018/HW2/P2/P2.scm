;;;if not using function
;;helpers
(define (intensity A) (apply + (color-image->rgb A)))
(define (greenness greenim) (apply (lambda(r g b) (/ g (+ r g b 1))) (color-image->rgb greenim)))
(define (redness coinim) (apply (lambda(r g b) (/ r (+ r g b 1))) (color-image->rgb coinim)))
(define evens
  (lambda (ls)
    (if (null? ls)
        '()
        (cons (car ls)
              (odds (cdr ls))))))
(define odds
  (lambda (ls)
    (if (null? ls)
        '()
        (evens (cdr ls)))))
(define merge
  (lambda (ls0 ls1)
    (cond ((null? ls0) ls1)
          ((null? ls1) ls0)
          ((> (car ls0) (car ls1))
           (cons (car ls1)
                 (merge ls0 (cdr ls1))))
          (else
           (cons (car ls0)
                 (merge (cdr ls0) ls1))))))
(define mergesort
  (lambda (ls)
    (cond ((null? ls) '())
          ((null? (cdr ls)) ls)
          (else
           (merge (mergesort (evens ls))
                  (mergesort (odds ls)))))))
(define vector-sort
  (lambda (vec)
    (list->vector (mergesort (vector->list vec)))))
(define incre
  (lambda (ls i)
    (/ (list-ref ls i) (list-ref ls (- i 1)))))
(define get-incre
  (lambda (increvec areals i)
    (if (< i (length areals))
	(begin
	  (vector-set! increvec i (incre areals i))
	  (get-incre increvec areals (+ i 1))))))
(define get-is
  (lambda (increvec indexvec increj indexj)
    (if (< increj (vector-length increvec))
	(begin
	  (if (> (vector-ref increvec increj) 1.22)
	      (begin
		(vector-set! indexvec indexj increj)
		(get-is increvec indexvec (+ increj 1)  (+ indexj 1)))
	      (get-is increvec indexvec (+ increj 1) indexj))))))
		  
;;input
(define coins (read-color-image "coins7.ppm"))

;;operations on area
;binary image
(define coins-bin (< (greenness coins) 0.78))
;denoise
(define coins-bin1 (open (close coins-bin)))
;make space
(define coins-bin2 (erode coins-bin1 (make-vector 2 (make-vector 2 1))))
;separate coins
(define coins-bin3 (open coins-bin2 (make-vector 40 (make-vector 40 1))))
(define coins-bin4 (erode coins-bin3 (make-vector 15 (make-vector 15 1))))
;smooth
(define coins-bin5 (open coins-bin4 (make-vector 34 (make-vector 34 1))))
;get areas
(define area-list (mergesort (vector->list (areas (label coins-bin5)))))

;;operations on color
;binary image
(define cent-bin (> (redness coins) 0.5))
(define cent-bin1 (close cent-bin (make-vector 5 (make-vector 5 1))))
(define cent-bin2 (open cent-bin1 (make-vector 5 (make-vector 5 1))))
(define cent-bin3 (erode cent-bin2 (make-vector 20 (make-vector 20 1))))
(define cent-area-vec (areas (label cent-bin3)))
(define one-cents (- (vector-length cent-area-vec) 1))

;;count coins
(define incre-vec (make-vector (length area-list)))
(get-incre incre-vec area-list 1)
(define index-vec (make-vector 3))
(get-is incre-vec index-vec 1 0)
(define quarters (- (vector-ref index-vec 2) (vector-ref index-vec 1)))
(define five-cents (- (vector-ref index-vec 1) (vector-ref index-vec 0)))
(define one-dines (- (vector-ref index-vec 0) one-cents))
(define total-cents (+ one-cents (* five-cents 5) (* one-dines 10) (* quarters 25)))


;;;function
(define area-list
  (lambda(coinim)
    (mergesort (vector->list (areas (label (open (erode (open (erode (open (close (< (greenness coinim) 0.78))) (make-vector 2 (make-vector 2 1))) (make-vector 40 (make-vector 40 1))) (make-vector 15 (make-vector 15 1))) (make-vector 34 (make-vector 34 1)))))))))
(define one-cents
  (lambda(coinim)
    (- (vector-length (areas (label (erode (open (close (> (redness coinim) 0.5) (make-vector 5 (make-vector 5 1))) (make-vector 5 (make-vector 5 1))) (make-vector 20 (make-vector 20 1)))))) 1)))
(define incre-v
  (lambda(coinim)
    (make-vector (length (area-list coinim)))))
(define index-vec (make-vector 3))
(define total-cents
  (lambda(coinim)
    (get-incre incre-vec (area-list coinim) 1)
    (get-is incre-vec index-vec 1 0)
    (+ (* (one-cents coinim) 1)
       (* (- (vector-ref index-vec 1) (vector-ref index-vec 0)) 5)
       (* (- (vector-ref index-vec 0) (one-cents coinim)) 10)
       (* (- (vector-ref index-vec 2) (vector-ref index-vec 1)) 25))))

;;test function
;replace [coins] with image "coins1~9.ppm" and do the following
(define coins (read-color-image "coins7.ppm"))
(define incre-vec (incre-v coins))
(total-cents coins)
