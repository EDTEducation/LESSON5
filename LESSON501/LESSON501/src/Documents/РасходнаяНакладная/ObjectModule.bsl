
Процедура ОбработкаПроведения(Отказ, Режим)
	
	
	Движения.Взаиморасчеты.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	Элемент = Блокировка.Добавить("РегистрНакопления.Взаиморасчеты");
	Элемент.УстановитьЗначение("Контрагент",Контрагент);
	Элемент.УстановитьЗначение("Валюта",Справочники.Валюты.РоссийскийРубль);
	Элемент.УстановитьЗначение("Расходная",Документы.РасходнаяНакладная.ПустаяСсылка());
	Элемент.Режим=РежимБлокировкиДанных.Исключительный;
	Блокировка.Заблокировать();
	
	Движения.Взаиморасчеты.Записывать = Истина;

	
	Запрос = новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВзаиморасчетыОстатки.СуммаВалОстаток,
	|	ВзаиморасчетыОстатки.Валюта
	|ИЗ
	|	РегистрНакопления.Взаиморасчеты.Остатки(
	|			&МоментВремени,
	|			Контрагент = &Контрагент
	|				И Расходная = &Пустая
	|				И Валюта = &Руб) КАК ВзаиморасчетыОстатки
	|ГДЕ
	|	ВзаиморасчетыОстатки.СуммаРубОстаток < 0";
	Запрос.УстановитьПараметр("МоментВремени",МоментВремени());
	Запрос.УстановитьПараметр("Контрагент",Контрагент);
	Запрос.УстановитьПараметр("Руб",Справочники.Валюты.НайтиПоКоду(810));
	Запрос.УстановитьПараметр("Пустая",Документы.РасходнаяНакладная.ПустаяСсылка());

	СуммаРубИтог=0;
	
	ОстатокВал = Сумма;
	
	выборка = Запрос.Выполнить().Выбрать();
	Если выборка.Следующий() Тогда
		СуммаАвансРуб = - выборка.СуммаВалОстаток;
		СуммаАвансаВал = СуммаАвансРуб/Курс;
		
		Движение = Движения.Взаиморасчеты.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Валюта = выборка.валюта;
		Движение.Расходная = Документы.РасходнаяНакладная.ПустаяСсылка();
		
		Движение.СуммаВал = МИН(СуммаАвансаВал,Сумма );
		
		СуммаРубИтог = СуммаРубИтог + Движение.СуммаВал * Курс;
	
		ОстатокВал = ОстатокВал- Движение.СуммаВал;
						
		
	КонецЕсли;	
	
	Если  ОстатокВал<>0 ТОгда
			
			Движение = Движения.Взаиморасчеты.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
			Движение.Период = Дата;
			Движение.Контрагент = Контрагент;
			Движение.Валюта = Валюта;
			Движение.Расходная = Ссылка;
			Движение.СуммаВал = ОстатокВал;
		
			СуммаРубИтог = СуммаРубИтог + Движение.СуммаВал * Курс;
			
	КонецЕсли;	

	

	Движение = Движения.Продажи.Добавить();
	Движение.Контрагент = Контрагент;
	Движение.Период = Дата;
	Движение.СуммаРуб = СуммаРубИтог;
	
	Движения.Продажи.Записывать = Истина;
	
	
	
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
