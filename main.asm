.def	temp = R16
.def	adclow = R17
.def	adchigh = R18

init:
	;PORT ayarları
	LDI		temp,	0xFF     ;0xff değerini register(kayıtçı)r16 ya yükle
	OUT		DDRD,	R16      ;port d deki tüm pinler cıkış     

	LDI		temp,	0x00
	OUT		DDRC,	temp

	LDI		temp,	0x00
	OUT		PORTC,	temp

	;PWM ayarları
	LDI		temp,	1<<WGM00 | 1<<COM0A1	; Fast PWM modu //  Karşılaştırmada 0C0A'yı temizle --> PD6 portu yani d6
	OUT		TCCR0A,	temp
	
	LDI		temp, 1<<CS01					;Clock Select'i  8 e böl
 	OUT		TCCR0B, temp

	;ADC ayarları

	LDI		temp,	1<<REFS0 | 1<<MUX0		;AVcc ye referans olarak// ADC1/PC1'i kullan
	STS		ADMUX,	temp

	LDI		temp,	1<<ADEN | 1<<ADPS0 | 1<<ADPS1 | 1<<ADPS2     // ADC aktif, saati böl /128
	STS		ADCSRA,	temp


loop:
	;karşılaştırmayı başlat
	LDS		temp,	ADCSRA
	ORI		temp,	1<<ADSC
	STS		ADCSRA,	temp

	;karşılaştırmayı bitir
	bekle:
		lds temp, ADCSRA
		sbrc temp,	ADSC
		rjmp bekle
	
  ;Aşağıdaki kodlar sadece bazı geçişleri göstermek için kullanıldı.
  ;Daha iyi sonuç almak için şu geçis operasyonlarını kullanın:
  ;ADLAR'ı (ADMUX'ta) 1'den Sola ayarlayın kayıtçıyı ayarlayın, ardından ADCH kayıtcısını kullanın.
	lds		adclow,		ADCL  ;adclow'u veri alanı konumu adcl içeriğiyle yükleyin
	lds		adchigh,	ADCH

	lsr		adclow ;adclow'u 2 ye böl
	lsr		adclow

	lsl		adchigh ;adchigh'ı 2 ye çarp
	lsl		adchigh
	lsl		adchigh
	lsl	    adchigh
	lsl		adchigh
	lsl		adchigh

	OR		adclow,		adchigh ;adclow veya adchigh çıkış değeri

	OUT		OCR0A,		adclow

	rjmp loop
