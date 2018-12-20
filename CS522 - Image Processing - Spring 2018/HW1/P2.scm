;;if not using function
;load files
(define frog (read-image "frog.pgm"))
(load "histogram.scm")
(load "P1.scm")
;cdfk
(define cdfk
  (lambda(k)
    (vector-ref (cumulative-distribution-function im) k)))
;map
(cumulative-distribution-function frog)
(image-map (lambda(k) (vector-ref cdf0 k)) frog)


;;function {histogram-equalize}
(define cdf0 (make-vector 256))
(define histogram-equalize
  (lambda(im)
    (cumulative-distribution-function im)
    (image-map (lambda(k) (vector-ref cdf0 k)) im)))
;test function
(define frog-hisequal (histogram-equalize frog))
(write-image frog-hisequal "frog-hisequal.pgm")
(plot-histogram frog-hisequal)
;use function
(define me (read-image "me.pgm"))
(define me-hisequal (histogram-equalize me))
(write-image me-hisequal "me-hisequal.pgm")
(plot-histogram me-hisequal)
