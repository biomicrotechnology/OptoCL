;Helper constants
Ch          =      1               ;DAC channel to use
DACOff      =      0               ;Value to set the DAC to when "off" (in V)
PAUSE       =      s(3600)         ;Maximum "open-loop" stimulation duration

;Configuration
            SET    0.01,1,0        ;msPerStep, DACscale, DACoffset

            VAR    V1,VFreq        ;For holding the frequency of each sequence
            VAR    V2,VSize        ;For holding the cosine amplitude
            VAR    V3,VOffset      ;For holding the cosine frequency


;Program start
            ;Stop any ongoing stimulation (Keyboard shortcut 'Q')
E0:     'Q  RATE   Ch,0            ;Stop cosine output
            DAC    Ch,DACOff       ;Set DAC value to "off"
            MARK   0               ;Digital mark 0
            
            ;TODO: sync

            ;Reset sinusoidal parameters
            SZ     Ch,0            ;Set cosine amplitude
            OFFSET Ch,0            ;Set cosine centre
            PHASE  Ch,180          ;Set initial cosine phase to start at minimum
            ANGLE  Ch,  0          ;Set cosine phase step
            HALT                   ;End of sequence

            ;Await stimulation sequence start

            ;Set parameters and start cosine (Keyboard shortcut 'S')
            ;Duration: 60ms (stimulation indefinite)
        'S  RATE   Ch,VFreq        ;Start stimulation
            CLRC   Ch              ;Clear wait flag
WAIT0:      WAITC  Ch,WAIT0        ;Wait for the next cycle
            RATE   Ch,0            ;Stop cosine output
            SZ     Ch,VSize        ;Set cosine amplitude
            OFFSET Ch,VOffset      ;Set cosine centre
            RATE   Ch,VFreq        ;Set rate and start cosine
            MARK   1               ;Digital mark 1
            DELAY  PAUSE           ;Wait for next sequence
            JUMP   E0              ;Stop if something goes wrong
