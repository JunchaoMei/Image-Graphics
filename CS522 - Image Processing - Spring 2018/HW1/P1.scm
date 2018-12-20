;;if not using function
;load file
(define frog (read-image "frog.pgm"))
(load "histogram.scm")
;get pmf vector
(plot-histogram frog)
(define pmf (histogram frog))
(vector? pmf)
(vector-length pmf)
(vector? (histogram frog))
;get rows and cols
(define Row (image-rows frog))
(define Col (image-cols frog))
;get length
(define len (vector-length pmf)) ;=>256
;recursion ;(cond (pred1 val1) (else valN))
(define cdp ;cumulative distribution point
  (lambda(j pmf)
    (cond ((= j 0) (vector-ref pmf 0)) (else (+ (cdp (- j 1) pmf) (vector-ref pmf j))))))
;get cdf
(define cdf0 (make-vector len))
(define set-cdf
  (lambda(pmf cdf0 end start) ;[start,end)
    (if (< start end)
	(begin
	  (vector-set! cdf0 start (cdp start pmf))
	  (set-cdf pmf cdf0 end (+ start 1))))))
(set-cdf pmf cdf0 len 0)

;;function {cumulative-distribution-function}
(load "histogram.scm")
(define cdf0 (make-vector 256))
(define cdp ;cumulative distribution point
  (lambda(j pmf)
    (cond ((= j 0) (vector-ref pmf 0)) (else (+ (cdp (- j 1) pmf) (vector-ref pmf j))))))
(define set-cdf
  (lambda(im pmf cdf0 end start) ;[start,end)
    (if (< start end)
	(begin
	  (vector-set! cdf0 start (* (cdp start pmf) 255 (/ 1 (image-rows im)) (/ 1(image-cols im))))
	  (set-cdf im pmf cdf0 end (+ start 1))))))
(define cumulative-distribution-function
  (lambda(im)
    (set-cdf im (histogram im) cdf0 256 0)
    cdf0))
(define (plot-cdf A)
  (let ((maximum (floor (fold max A)))
        (h (cumulative-distribution-function A))
        (output-port (open-output-file "cdf.txt")))
    (fprintf output-port "plot [0:%g] '-' title 'c.d.f.' with lines\n" maximum)
    (do ((i 0 (+ i 1))) ((= i maximum))
      (fprintf output-port "%g\n" (vector-ref h i)))
    (fprintf output-port "exit\n")
    (close-output-port output-port)
    (system "gnuplot -persist < cdf.txt &")
    (void)))
;test function
(define frog (read-image "frog.pgm"))
(define frog-cdf (cumulative-distribution-function frog))
frog-cdf
(vector? frog-cdf)
(plot-cdf frog)
;use function
(define me (read-image "me.pgm"))
(plot-histogram me)
(cumulative-distribution-function me)
(plot-cdf me)
