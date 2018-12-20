;;if not using function
;load files
(define frog (read-image "frog.pgm"))
(define rad (read-image "radiation.pgm"))
(define croppedrad (image-crop rad 0 0 (image-rows frog) (image-cols frog)))
(write-image croppedrad "croppedrad.pgm")
;cdf & icdf
(define cdf1 (list->vector (vector->list (cumulative-distribution-function frog))))
(define cdf2 (list->vector (vector->list (cumulative-distribution-function me))))
(define cdfk
  (lambda(k)
    (vector-ref cdf1 k)))
(define icdfj
  (lambda(j k)
    (cond ((>= (vector-ref cdf2 k) j) k) (else (icdfj j (+ k 1))))))
(icdfj (cdfk 100) 0)
;matk
(define matk
  (lambda(k)
    (icdfj (cdfk k) 0)))
;test
(image-map matk frog)
(plot-histogram (image-map matk frog))


;;function {histogram-match}
(define cdf (lambda(im) (list->vector (vector->list (cumulative-distribution-function im)))))
(define cdfk
  (lambda(cdf1 k)
    (vector-ref cdf1 k)))
(define icdfj
  (lambda(cdf2 j k)
    (cond ((>= (vector-ref cdf2 k) j) k) (else (icdfj cdf2 j (+ k 1))))))
(define histogram-match
  (lambda(im1 im2)
    (define cdf1 (cdf im1))
    (define cdf2 (cdf im2))
    (image-map (lambda(k) (icdfj cdf2 (cdfk cdf1 k) 0)) im1)))
;test function
(histogram-match croppedrad frog)
(define croppedrad_match_frog (histogram-match croppedrad frog))
(write-image croppedrad_match_frog "croppedrad_match_frog.pgm")
(plot-histogram croppedrad_match_frog)
;use function
(define frog_match_croppedrad (histogram-match frog croppedrad))
(write-image frog_match_croppedrad "frog_match_croppedrad.pgm")
(plot-histogram frog_match_croppedrad)
