(load "from2.1.scm")
;;helpers
(define ceiling
  (lambda(x)
    (+ (floor x) 1)))
(define arctan
  (lambda(atanget i j a b)
    (cond ((< j b) (+ atanget (degree->rad 270)))
	  (else (+ atanget (degree->rad 90))))))
(define R
  (lambda(im)
    (/ (- (min (image-rows im) (image-cols im)) 1) 2)))
(define Col
  (lambda(R)
    (ceiling (* 2 pi R))))
(define a
  (lambda(im)
    (/ (- (image-rows im) 1) 2)))
(define b
  (lambda(im)
    (/ (- (image-cols im) 1) 2)))
(define I
  (lambda(i j im)
    (dist i j (a im) (b im))))
(define J
  (lambda(R theta)
    (round (* R theta))))
(define incircle
  (lambda(i j im)
    (<= (I i j im) (R im))))
(define comij
  (lambda(imcom blkcom i j)
    (if (incircle i j imcom)
	(image-set! blkcom (I i j imcom) (J (R imcom) (theta i j (a imcom) (b imcom))) (image-ref imcom i j)))))
(define comloop
  (lambda(i j imin jmin imax jmax imcom blkcom)
    (if (<= i imax)
	(begin
	  (if (<= j jmax)
	      (begin
		(comij imcom blkcom i j)
		(comloop i (+ j 1) imin jmin imax jmax imcom blkcom))
	      (comloop (+ i 1) jmin imin jmin imax jmax imcom blkcom))))))
;;variables
(define cone (read-color-image "cone.ppm"))
(define conered (color-image-red cone))
(define conegreen (color-image-green cone))
(define coneblue (color-image-blue cone))
(define blackred (make-image (+ (R cone) 1) (Col (R cone))))
(define blackgreen (make-image (+ (R cone) 1) (Col (R cone))))
(define blackblue (make-image (+ (R cone) 1) (Col (R cone))))

;;function
(define depolar-image-com
  (lambda(im func)
    (define blkcom (make-image (+ (R im) 1) (Col (R im))))
    (comloop 0 0 0 0 (- (image-rows im) 1) (- (image-cols im) 1) (func im) blkcom) blkcom))
(define depolar-image
  (lambda(im)
    (rgb->color-image (depolar-image-com im color-image-red) (depolar-image-com im color-image-green) (depolar-image-com im color-image-blue))))
;;test function
(write-image (depolar-image-com cone color-image-red) "cone-depolar-red.pgm")
(write-image (depolar-image-com cone color-image-green) "cone-depolar-green.pgm")
(write-image (depolar-image-com cone color-image-blue) "cone-depolar-blue.pgm")
(write-color-image (depolar-image cone) "cone-depolar.ppm")
