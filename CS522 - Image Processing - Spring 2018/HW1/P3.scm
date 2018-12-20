;;if not using function
;load files
(define frog (read-image "frog.pgm"))
(define me (read-image "me.pgm"))
(load "histogram.scm")
(define cdf0 (make-vector 256))
;cdfk
(define cdfk
  (lambda(im k)
    (vector-ref (cumulative-distribution-function im) k)))
;test cdfk
(cdfk me 3)
(cdfk frog 3)
;icdfj
(define icdfj
  (lambda(j k)
    (cond ((>= (vector-ref cdf0 k) j) k) (else (icdfj j (+ k 1))))))
;test
(cumulative-distribution-function frog)
(icdfj 50 0)
(cumulative-distribution-function me)
(icdfj 50 0)


;;function {inverse-cumulative-distribution-function}
(define icdf0 (make-vector 256))
(define set-icdf
  (lambda(icdf0 end start) ;[start,end)
    (if (< start end)
	(begin
	  (vector-set! icdf0 start (icdfj start 0))
	  (set-icdf icdf0 end (+ start 1))))))
(define inverse-cumulative-distribution-function
  (lambda(im)
    (cumulative-distribution-function im)
    (set-icdf icdf0 255 0)
    (vector-set! icdf0 255 255)
    icdf0))
(define (plot-icdf A)
  (let ((maximum (floor (fold max A)))
        (h (inverse-cumulative-distribution-function A))
        (output-port (open-output-file "icdf.txt")))
    (fprintf output-port "plot [0:%g] '-' title 'i.c.d.f.' with lines\n" maximum)
    (do ((i 0 (+ i 1))) ((= i maximum))
      (fprintf output-port "%g\n" (vector-ref h i)))
    (fprintf output-port "exit\n")
    (close-output-port output-port)
    (system "gnuplot -persist < icdf.txt &")
    (void)))
;test function
(define frog-icdf (inverse-cumulative-distribution-function frog))
(vector? frog-icdf)
(vector-length frog-icdf)
(plot-icdf frog)
;use function
(inverse-cumulative-distribution-function me)
(plot-icdf me)
