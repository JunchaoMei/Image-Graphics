;;;[P3.1]
;;helpers
(define powersum
  (lambda(tag n)
    (cond ((= n 0) 0)
	  (else
	   (+ (expt (magnitude (fft (read-image (string-append tag "/" tag (number->string n) ".pgm")))) 2) (powersum tag (- n 1)))))))
(define poweraverage
  (lambda(tag n)
    (/ (powersum tag n) n)))
(define testing
  (lambda(filter tag n)
    (cond ((= n 0) (display "end"))
	  (else
	   (begin
	     (write-image (real-part (ifft (* (fft (read-image (string-append tag "/" tag (number->string n) ".pgm"))) filter))) (string-append tag (number->string n) "-after.pgm"))
	     (testing filter tag (- n 1)))))))
;;variables
(define s1 (read-image "signal/signal1.pgm"))
(define ps1 (expt (magnitude (fft s1)) 2))
(define s2 (read-image "signal/signal2.pgm"))
(define ps2 (expt (magnitude (fft s2)) 2))


;;signal
(define S (poweraverage "signal" 24))
(write-image (log S) "log(S).pgm")
;;noise
(define N (poweraverage "noise" 22))
(write-image (log N) "log(N).pgm")
;;Wiener
(define Wiener (/ S (+ S N)))
(write-image Wiener "Wiener.pgm")


;;test
(define t1-before (read-image "test/test1.pgm"))
(define t1-after (real-part (ifft (* (fft t1-before) Wiener))))
(testing Wiener "test" 6)
