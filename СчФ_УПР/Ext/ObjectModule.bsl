﻿
#Область Переменные

Перем 	ИННСпортмастер;
Перем	ИННСанинбев;	
Перем 	ИННПочтаРоссии;
Перем 	ИННКокаКола;
Перем 	ИННФерреро;
Перем 	ИННМВИДЕО;
Перем 	ИННМПК;
Перем   ИННПолипластик;
Перем	ИННБалтика;
Перем 	ИННСетраЛубрикатс;
Перем   ИННКордиант;
Перем  	ИННКонтрагента;
Перем  	ИННАвтодизель;

Перем ВариантМакета;

#КонецОбласти 

Функция ПолучитьМакетСчФ(ДатаСчФ)
	
	Если ДатаСчФ <= '20210701' Тогда
		Макет =  ПолучитьМакет("СчФ_Типовой981"); 	
	Иначе 
		Макет = ПолучитьМакет("СчФ_Типовой584");
	КонецЕсли; 
	
	Возврат  Макет;
	
КонецФункции // ПолучитьМакет()

Функция ДокументЗаполненНекорректно(ДокументПечати)
	Результат = Ложь;
	Если ДокументПечати.Филиал.Пустая() Тогда
		Сообщить("Филиал не указан!");
		Результат = Истина;
	Иначе
		Если НЕ ЗначениеЗаполнено(ДокументПечати.Филиал.ГородФилиала) Тогда
			Сообщить("Город Филиала не указан!");
			Результат = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

Функция ПолучитьТаблицуДокумента(СсылкаНаОбъект)
	
	Запрос = новый запрос;
	Запрос.УстановитьПараметр("МассивОбъектов",СсылкаНаОбъект);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	РеализацияТоваровУслугУслуги.Номенклатура КАК Номенклатура,
	               |	РеализацияТоваровУслугУслуги.Сумма КАК Сумма,
	               |	РеализацияТоваровУслугУслуги.Количество КАК Количество,
	               |	РеализацияТоваровУслугУслуги.Цена КАК Цена,
	               |	РеализацияТоваровУслугУслуги.Ссылка КАК Ссылка,
	               |	РеализацияТоваровУслугУслуги.Маршрут КАК Маршрут,
	               |	РеализацияТоваровУслугУслуги.Заявка КАК Заявка,
	               |	РеализацияТоваровУслугУслуги.СуммаНДС КАК СуммаНДС,
	               |	РеализацияТоваровУслугУслуги.СуммаНДС + РеализацияТоваровУслугУслуги.Сумма КАК Всего,
	               |	РеализацияТоваровУслугУслуги.НомерСтроки КАК НомерСтроки,
	               |	РеализацияТоваровУслугУслуги.Ссылка.Номер КАК НомерДок,
	               |	РеализацияТоваровУслугУслуги.Ссылка.Дата КАК ДатаДок,
	               |	РеализацияТоваровУслугУслуги.Ссылка.ВалютаДокумента КАК Валюта,
	               |	РеализацияТоваровУслугУслуги.Ссылка.КурсВзаиморасчетов КАК Курс,
	               |	РеализацияТоваровУслугУслуги.Номенклатура.Наименование КАК ТоварНаименование,
	               |	РеализацияТоваровУслугУслуги.СтавкаНДС КАК СтавкаНДС,
	               |	РеализацияТоваровУслугУслуги.НомерСтроки КАК НомерСтроки1
	               |ИЗ
	               |	Документ.РеализацияТоваровУслуг.Услуги КАК РеализацияТоваровУслугУслуги
	               |ГДЕ
	               |	РеализацияТоваровУслугУслуги.Ссылка В(&МассивОбъектов)
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	Ссылка,
	               |	НомерСтроки";
	
	ОбщаяВыборка = Запрос.Выполнить().Выгрузить();
	
	Возврат ОбщаяВыборка;
КонецФункции // ПолучитьТаблицуДокумента()

Функция ПолучитьСтрокуНДС(ВалютаД,НДС,Курс)
	
	СтвкаНДС 	= Перечисления.СтавкиНДС.НДС18;
	
	СумНДС 		= Формат(НДС * Курс, "ЧДЦ=2")+?(ЗначениеЗаполнено(ВалютаД)," "+ВалютаД.Наименование,"");
	СтрНДС 		= "НДС("+(СтвкаНДС)+")- "+СумНДС; 
	
	Возврат СтрНДС;
	
КонецФункции // ПолучитьСтрокуНДС()

// Функция формирует табличный документ с Внешней печатной формой
//
// Возвращаемое значение:
//  Табличный документ - печатная форма акта
Функция ПечатьВнешнейПечатнойФормы(МассивОбъектов, ОбъектыПечати ) Экспорт
	// вызов всех вариантов печати Актов определяемых по ИНН контрагента
	
	ТабДок = Новый ТабличныйДокумент;
	Если НЕ МассивОбъектов.Количество()=0 Тогда
		
		ДокументПечати  = МассивОбъектов[0];
		Если ДокументЗаполненНекорректно(ДокументПечати) Тогда
			Возврат ТабДок;
		КонецЕсли;
		
		РеквизитыОбъектаПечати = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДокументПечати, "Контрагент, Дата");
		Контрагент	= РеквизитыОбъектаПечати.Контрагент;
		
		Если РеквизитыОбъектаПечати.Дата <= '20210701' Тогда
			Макет =  ПолучитьМакет("СчФ_Типовой981"); 	
			ВариантМакета = "981";
		Иначе 
			Макет = ПолучитьМакет("СчФ_Типовой584");
			ВариантМакета = "584";
		КонецЕсли; 

		ТабДок = ПолучитьТабДок_Типовой(Макет, ДокументПечати, ОбъектыПечати, ТабДок);
		
		Возврат ТабДок;
		
	КонецЕсли;
	
	Возврат ТабДок;
	
КонецФункции // 

Функция ПолучитьТабДок_Типовой(Макет, СсылкаНаОбъект, ОбъектыПечати, ТабДок) Экспорт
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	// Шапка
	СведенияОПоставщике = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(СсылкаНаОбъект.Организация, СсылкаНаОбъект.Дата);
	
	ПредставлениеПоставщика =  ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "ПолноеНаименование,");
	
	АдресПоставщика = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПоставщике, "ЮридическийАдрес,");
	
	ИННПоставщика = СсылкаНаОбъект.Организация.ИНН;
	КПППоставщика = СсылкаНаОбъект.Организация.КПП;
	
	// грузополучатель	
	
	СведенияОПокупателе = БухгалтерскийУчетПереопределяемый.СведенияОЮрФизЛице(СсылкаНаОбъект.Контрагент,  СсылкаНаОбъект.Дата);
	
	// Наименование покупателя
	ПредставлениеПокупателя = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПокупателе, "НаименованиеДляПечатныхФорм,");
	
	// Адрес покупателя
	АдресПокупателя = ОбщегоНазначенияБПВызовСервера.ОписаниеОрганизации(СведенияОПокупателе, "ЮридическийАдрес,");	
	
	// ИНН и КПП покупателя
	ИННпокупателя = СсылкаНаОбъект.Контрагент.ИНН;
	
	КППпокупателя = СсылкаНаОбъект.Контрагент.КПП;	
	
	Если ЗначениеЗаполнено(КППпокупателя) Тогда
		ИННпокупателя = ИННпокупателя; // + " \ " + КППпокупателя;
	КонецЕсли;
	
	// Валюта
	Если ЗначениеЗаполнено(СсылкаНаОбъект.ВалютаДокумента) Тогда
		ВалютаНаименование = СсылкаНаОбъект.ВалютаДокумента.НаименованиеПолное + ", " + СсылкаНаОбъект.ВалютаДокумента.Код;
	Иначе
		ВалютаНаименование = "";
	КонецЕсли;
	
	НазваниеУслугиКонтрагента = ""; НазваниеУслугиВШапкеАкта=""; КППКонтрагента = "";
	ОтветственныйКонтрагента = Справочники.яРуководителиКонтрагента.ВернутьКонтактноеЛицо(СсылкаНаОбъект.Контрагент, СсылкаНаОбъект.Филиал);	
	Если НЕ ОтветственныйКонтрагента.Пустая() Тогда		
		КППВФилиале = ОтветственныйКонтрагента.КППВФилиале;
		НазваниеУслугиКонтрагента = ОтветственныйКонтрагента.НаименованиеУслуги;		
		НазваниеУслугиВШапкеАкта = ОтветственныйКонтрагента.НазваниеУслугиВШапкеАкта;
	КонецЕсли; 
	
	Если ЗначениеЗаполнено(КППВФилиале) Тогда	
		КПППокупателя = КППВФилиале;	
	КонецЕсли;	
	
	Если СсылкаНаОбъект.ВалютаДокумента.Наименование="USD" Тогда
		ИННпокупателя = "";
		КПППокупателя = "";
	КонецЕсли; 
	
	////////////////////////////////////////////////////////////////////////////////////////////////	
	// табличная часть	
	ОбщаяВыборка = ПолучитьТаблицуДокумента(СсылкаНаОбъект);
	Отбор = Новый Структура;
	Отбор.Вставить("Ссылка", СсылкаНаОбъект);
	Выборка = ОбщаяВыборка.НайтиСтроки(Отбор);
	
	ОбластьМакета = Макет.ПолучитьОбласть("Шапка");	
	ОбластьМакета.Параметры.Номер = СсылкаНаОбъект.Номер;
	ОбластьМакета.Параметры.Дата = Формат(СсылкаНаОбъект.Дата, "ДЛФ='ДД'");
	ОбластьМакета.Параметры.НомерИсправления = "--";
	ОбластьМакета.Параметры.ДатаИсправления = "--";
	
	Если ВариантМакета = "981" Тогда
		// в старом варианте названия формировалось в представлении
		ОбластьМакета.Параметры.ПредставлениеПоставщика = "Продавец: " + ПредставлениеПоставщика;
		ОбластьМакета.Параметры.АдресПоставщика = "Адрес: " + АдресПоставщика;
		ОбластьМакета.Параметры.ИННПоставщика = "ИНН/КПП продавца: " + ИННПоставщика + ?(ЗначениеЗаполнено(КПППоставщика), "/" + КПППоставщика, "");
		ОбластьМакета.Параметры.ПредставлениеГрузоотправителя = "Грузоотправитель и его адрес: --";
		ОбластьМакета.Параметры.ПредставлениеГрузополучателя = "Грузополучатель и его адрес:  --";
		ОбластьМакета.Параметры.ПоДокументу = "К платежно-расчетному документу №   от";
		ОбластьМакета.Параметры.ПредставлениеПокупателя = "Покупатель: " + ПредставлениеПокупателя;
		ОбластьМакета.Параметры.АдресПокупателя = "Адрес: " + АдресПокупателя;
		ОбластьМакета.Параметры.ИННПокупателя = "ИНН/КПП покупателя: " + ИННПокупателя + ?(ЗначениеЗаполнено(КПППокупателя), "/" + КПППокупателя, "");
		ОбластьМакета.Параметры.Валюта = "Валюта: наименование, код " + ВалютаНаименование;
	Иначе
		// в новом варианте представления полей в макете
		ОбластьМакета.Параметры.ПредставлениеПоставщика = ПредставлениеПоставщика;
		ОбластьМакета.Параметры.АдресПоставщика = АдресПоставщика;
		ОбластьМакета.Параметры.ИННПоставщика = ИННПоставщика + ?(ЗначениеЗаполнено(КПППоставщика), "/" + КПППоставщика, "");
		ОбластьМакета.Параметры.ПредставлениеГрузоотправителя = "--";
		ОбластьМакета.Параметры.ПредставлениеГрузополучателя = "--";
		ОбластьМакета.Параметры.ПоДокументу = "№ -- от --";
		
		ШаблонПредставления = "%1 %2 от %3";
		ПредставлениеДокумента = "";
		Если Выборка.Количество() > 1 Тогда
			ВерхняяГраница = Выборка.Количество();
			ПредставлениеДокумента = СтрШаблон("№ п/п 1-%1 %2 от %3", ВерхняяГраница, СокрЛП(СсылкаНаОбъект.Номер), Формат(СсылкаНаОбъект.Дата, "ДФ=dd.MM.yyyy"));
		Иначе
			ПредставлениеДокумента = СтрШаблон("№ п/п 1 %1 от %2", СокрЛП(СсылкаНаОбъект.Номер), Формат(СсылкаНаОбъект.Дата, "ДФ=dd.MM.yyyy"));
		КонецЕсли; 
		ОбластьМакета.Параметры.ДокументыОбОтгрузке = ПредставлениеДокумента;
		ОбластьМакета.Параметры.ПредставлениеПокупателя = ПредставлениеПокупателя;
		ОбластьМакета.Параметры.АдресПокупателя = АдресПокупателя;
		ОбластьМакета.Параметры.ИННПокупателя = ИННПокупателя + ?(ЗначениеЗаполнено(КПППокупателя), "/" + КПППокупателя, "");
		ОбластьМакета.Параметры.Валюта = ВалютаНаименование;
	КонецЕсли; 
	
	ТабДок.Вывести(ОбластьМакета);
	
	// нумерация листа
	//ОбластьНумерация = Макет.ПолучитьОбласть("НумерацияЛистов");
	//ОбластьНумерация.Параметры.Номер = "[&НомерСтраницы]";
	//Табдок.Вывести(ОбластьНумерация);
	
	// Вывод заголовка таблицы	
	ОбластьМакета = Макет.ПолучитьОбласть("ЗаголовокТаблицы");
	ТабДок.Вывести(ОбластьМакета);
	
	
	ИтогоСумма = 0;
	ИтогоНДС   = 0;  
	ИтогоВего  = 0;
	Режим      = 3; // Акт
	
	НастройкиПечати = яОбщийМодуль.ВернутьНастройкиПечатиКонтрагента(СсылкаНаОбъект.Контрагент);
	
	Для Каждого Стр из Выборка Цикл
		
		Заявка 				= Стр.Заявка;
		Ном   				= Стр.НомерСтроки;
		
		ЭтоПростой = Ложь;
		Если ТипЗнч(Заявка) = Тип("ДокументСсылка.яПретензия") Тогда
			ЭтоПростой = Истина;
			НастройкиПечати = яОбщийМодуль.ВернутьНастройкиПечатиПретензия();
			Заявка = Заявка.Заявка; //для простоя надо брать данные из док основания претензии
		КонецЕсли;
		
		Если Заявка.Пустая() Тогда
			ФИОВодителя 		= "";			
		Иначе
			ПараметрыПеревозки 	= Заявка.ПараметрыПеревозки[0];
			ФИОВодителя 		= ПараметрыПеревозки.Водитель.ФИО;
		КонецЕсли; 
		
		СтавкаНДС = Стр.СтавкаНДС;
		Цена = Стр.Сумма;
		Сумма = Стр.Сумма;
		НДС   = Стр.СуммаНДС;
		Всего = Сумма+НДС;
		
		Если Заявка.Пустая() Тогда
			НаименованиеТовара = Стр.ТоварНаименование;
		Иначе
			НаименованиеТовара = яОбщийМодуль.СформироватьСтрокуНаименованиеТовара(Стр, НастройкиПечати, "СчФ", ЭтоПростой);
		КонецЕсли; 

		ОбластьСтрока 	= Макет.ПолучитьОбласть("Строка");
		
		Если НастройкиПечати.СчФ_ПрочеркиВместоЕдИзм Тогда
			ЕдИзм 		= "---";
			ЕдИзмКод 	= "---";
		Иначе
			ЕдИзм 		= "шт";
			ЕдИзмКод 	= "796";
		КонецЕсли; 
		
		Если ИННКонтрагента = ИННКордиант Тогда						
			Цена = Цена;
			Колво 	= "---";
		ИначеЕсли НастройкиПечати.СчФ_ПрочеркиВместоКолваЦены Тогда
			Цена 	= "---";
			Колво 	= "---";		
		Иначе
			Цена = Цена;
			Колво = 1;			
		КонецЕсли; 
		
		Если ЭтоПростой Тогда		
			Если ИННКонтрагента = ИННМВИДЕО Тогда
				ЕдИзм 		= "ч";
				ЕдИзмКод 	= "356";				
				Цена 		= 200;
				Колво 		= Сумма / 200;
			Иначе
				ЕдИзм 		= "---";
				ЕдИзмКод 	= "---";				
			КонецЕсли;			
		КонецЕсли; 
		Попытка
			ОбластьСтрока.Параметры.НомерСтроки = Стр.НомерСтроки; 	
		Исключение
		    //ОписаниеОшибки()
		КонецПопытки; 
		
		ОбластьСтрока.Параметры.ТоварНаименование = НаименованиеТовара;
		ОбластьСтрока.Параметры.ЕдиницаИзмеренияКод = ЕдИзмКод;	
		ОбластьСтрока.Параметры.ЕдиницаИзмерения = ЕдИзм;	
		ОбластьСтрока.Параметры.Количество	 = Колво;
		ОбластьСтрока.Параметры.Цена = Цена;
		ОбластьСтрока.Параметры.Стоимость = Сумма;
		ОбластьСтрока.Параметры.Акциз = "без акциза";	
		ОбластьСтрока.Параметры.СтавкаНДС = СтавкаНДС;
		
		Если (ИННКонтрагента = ИННМВИДЕО) И ЭтоПростой Тогда		
	        ОбластьСтрока.Параметры.СуммаНДС = "без НДС";	
		Иначе
			ОбластьСтрока.Параметры.СуммаНДС = НДС;	
		КонецЕсли;
		
		ОбластьСтрока.Параметры.Всего = Сумма + НДС;
		ОбластьСтрока.Параметры.СтранаПроисхожденияКод = "";	
		ОбластьСтрока.Параметры.ПредставлениеСтраны = "";
		
		Попытка
			ОбластьСтрока.Параметры.ПредставлениеГТД = "";	
		Исключение
		    //ОписаниеОшибки()
		КонецПопытки; 
		
		
		ТабДок.Вывести(ОбластьСтрока);		
		
	КонецЦикла;

	// итоги //////////////////
	ИтСумма = СсылкаНаОбъект.Услуги.Итог("Сумма");
	ИтНДС   = СсылкаНаОбъект.Услуги.Итог("СуммаНДС");
	ИтВсего = ИтСумма+ИтНДС;	
	
	ОбластьИтоги 	= Макет.ПолучитьОбласть("Итого");
	
	ОбластьИтоги.Параметры.ИтогоСтоимость	= ИтСумма;
	
	ОбластьИтоги.Параметры.ИтогоСуммаНДС	= ИтНДС;
	
	ОбластьИтоги.Параметры.ИтогоВсего 	= ИтВсего;
	
	ТабДок.Вывести(ОбластьИтоги);	
	
	// подвал ////////////////////
	ОбластьПодвал	= Макет.ПолучитьОбласть("Подвал");
	
	Параметры = Новый Структура("Организация,Период,ОтветственноеЛицо",СсылкаНаОбъект.Организация, СсылкаНаОбъект.Дата, Перечисления.ОтветственныеЛицаОрганизаций.Руководитель); 	
	ПодписьРуководителя =  БухгалтерскиеОтчетыВызовСервера.ПолучитьДанныеОтветственногоЛица(Параметры).РасшифровкаПодписи;
	Если НЕ ЗначениеЗаполнено(ПодписьРуководителя) Тогда
		ПодписьРуководителя ="#не заполнено#";
	КонецЕсли; 

	ОбластьПодвал.Параметры.ФИОРуководителя = ПодписьРуководителя;
	ОбластьПодвал.Параметры.ФИОГлавногоБухгалтера = ПодписьРуководителя;
	ОбластьПодвал.Параметры.ФИОПБОЮЛ = "";
	
	ПечататьФаксимиле = Ложь;
	Если ПечататьФаксимиле Тогда
		ПодписиСсылки = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Параметры.Организация, "ФайлПодписьРуководителя,ФайлПодписьГлавногоБухгалтера");
		
		АдресФайлаПечати = ПрисоединенныеФайлы.ПолучитьДанныеФайла(ПодписиСсылки.ФайлПодписьРуководителя, Новый УникальныйИдентификатор).СсылкаНаДвоичныеДанныеФайла;
		ДанныеПодписи1 = ПолучитьИзВременногоХранилища(АдресФайлаПечати);
		ОбластьПОдвал.Рисунки.ФаксимилеРуководитель.Картинка = Новый Картинка(ДанныеПодписи1);
		
		АдресФайлаПечати = ПрисоединенныеФайлы.ПолучитьДанныеФайла(ПодписиСсылки.ФайлПодписьГлавногоБухгалтера, Новый УникальныйИдентификатор).СсылкаНаДвоичныеДанныеФайла;
		ДанныеПодписи2 = ПолучитьИзВременногоХранилища(АдресФайлаПечати);
		ОбластьПОдвал.Рисунки.ФаксимилеГлавныйБухгалтер.Картинка = Новый Картинка(ДанныеПодписи2);;
	Иначе
		ОбластьПодвал.Рисунки.Удалить(ОбластьПодвал.Рисунки.ФаксимилеРуководитель);
		ОбластьПодвал.Рисунки.Удалить(ОбластьПодвал.Рисунки.ФаксимилеГлавныйБухгалтер);
		ОбластьПодвал.Рисунки.Удалить(ОбластьПодвал.Рисунки.ФаксимилеПредприниматель);
	КонецЕсли; 	
	
	ТабДок.Вывести(ОбластьПодвал);
	
	ТабДок.ВывестиГоризонтальныйРазделительСтраниц();
	ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	ТабДок.АвтоМасштаб = Истина;
	
	// вывод подписи руководителя
	
	ТабДок.ВерхнийКолонтитул.НачальнаяСтраница = 2;
	ТабДок.ВерхнийКолонтитул.ВертикальноеПоложение = ВертикальноеПоложение.Низ;
	ТабДок.ВерхнийКолонтитул.ТекстСлева = "Лист [&НомерСтраницы] сч/ф № " + СокрЛП(СсылкаНаОбъект.Номер) + " от " + Формат(СсылкаНаОбъект.Дата, "ДФ=dd.MM.yyyy");
	ТабДок.ВерхнийКолонтитул.Выводить = Истина;
	
	Возврат ТабДок;
	
КонецФункции

// Экспортная процедура печати, вызываемая из основной программы
//
// Параметры:
// ВХОДЯЩИЕ:
//  МассивОбъектовНазначения - Массив - список объектов ссылочного типа для печати документа
//                 Как правило, содержит один элемент с ссылкой на вызвавший форму объект (документ, справочник)
//
// ИСХОДЯЩИЕ:
//  КоллекцияПечатныхФорм - ТаблицаЗначений - таблица сформированных табличных документов.
//                 Как правило, содержит одну строку с именем текущей печатной формы
//  ОбъектыПечати - СписокЗначений - список объектов печати. 
//  ПараметрыВывода - Структура - Параметры сформированных табличных документов. Содержит поля:
//  						ДоступнаПечатьПоКомплектно - булево - по умолчанию Ложь
//							ПолучательЭлектронногоПисьма
//							ОтправительЭлектронногоПисьма
//
Процедура Печать(МассивОбъектовНазначения, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "СчФ_УПР") Тогда 
		ТабличныйДокумент = ПечатьВнешнейПечатнойФормы(МассивОбъектовНазначения, ОбъектыПечати);
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(КоллекцияПечатныхФорм, "СчФ_УПР", "СчФ УПР", ТабличныйДокумент);
	КонецЕсли;
	
КонецПроцедуры

#Область СведенияОВнешнейОбработке
// Сервисная экспортная функция. Вызывается в основной программе при регистрации обработки в информационной базе
// Возвращает структуру с параметрами регистрации
//
// Возвращаемое значение:
//		Структура с полями:
//			Вид - строка, вид обработки, один из возможных: "ДополнительнаяОбработка", "ДополнительныйОтчет", 
//					"ЗаполнениеОбъекта", "Отчет", "ПечатнаяФорма", "СозданиеСвязанныхОбъектов"
//			Назначение - Массив строк имен объектов метаданных в формате: 
//					<ИмяКлассаОбъектаМетаданного>.[ * | <ИмяОбъектаМетаданных>]. 
//					Например, "Документ.СчФЗаказ" или "Справочник.*". Параметр имеет смысл только для назначаемых обработок, для глобальных может не задаваться.
//			Наименование - строка - Наименование обработки, которым будет заполнено наименование элемента справочника по умолчанию.
//			Информация  - строка - Краткая информация или описание по обработке.
//			Версия - строка - Версия обработки в формате “<старший номер>.<младший номер>” используется при загрузке обработок в информационную базу.
//			БезопасныйРежим - булево - Принимает значение Истина или Ложь, в зависимости от того, требуется ли устанавливать или отключать безопасный режим 
//							исполнения обработок. Если истина, обработка будет запущена в безопасном режиме. 
//
Функция СведенияОВнешнейОбработке() Экспорт
	//Инициализируем структуру с параметрами регистрации    	
	ПараметрыРегистрации = Новый Структура;
	// Первый параметр, который мы должны указать - это какой вид обработки системе должна зарегистрировать.
	// Допустимые типы: ДополнительнаяОбработка, ДополнительныйОтчет, ЗаполнениеОбъекта, Отчет, ПечатнаяФорма, СозданиеСвязанныхОбъектов
	ПараметрыРегистрации.Вставить("Вид", "ПечатнаяФорма"); //может быть - ПечатнаяФорма, ЗаполнениеОбъекта, ДополнительныйОтчет, СозданиеСвязанныхОбъектов...
	
	МассивНазначений = Новый Массив;
	// Теперь нам необходимо передать в виде массива имен, к чему будет подключена наша ВПФ
	// Имейте ввиду, что можно задать имя в таком виде: Документ.* - в этом случае обработка будет подключена ко всем документам в системе,
	// которые поддерживают механизм ВПФ
	МассивНазначений.Добавить("Документ.РеализацияТоваровУслуг"); //Указываем документ к которому делаем внешнюю печ. форму   		
	ПараметрыРегистрации.Вставить("Назначение", МассивНазначений);
	
	ПараметрыРегистрации.Вставить("Наименование", "СчФ (УПР)"); //имя под которым обработка будет зарегестрирована в справочнике внешних обработок
	ПараметрыРегистрации.Вставить("БезопасныйРежим", ЛОЖЬ);  // Зададим право обработке на использование безопасного режима. Более подробно можно узнать в справке к платформе (метод УстановитьБезопасныйРежим)
	ПараметрыРегистрации.Вставить("Версия", "8.3.001");   // эти два параметра играют больше информационную роль,
	ПараметрыРегистрации.Вставить("Информация", "СчФ (УПР)"); // т.е. это то, что будет видеть пользователь в информации к обработке
	
	// Создадим таблицу команд (подробнее смотрим ниже)
	ТаблицаКоманд = ПолучитьТаблицуКоманд();
	ДобавитьКоманду(ТаблицаКоманд, "СчФ (УПР)", "СчФ_УПР", "ВызовСерверногоМетода", Истина, "ПечатьMXL");
	
	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);
	
	Возврат ПараметрыРегистрации; 	
КонецФункции
#КонецОбласти

#Область Вспомогательное
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ РЕГИСТРАЦИИ ОБРАБОТКИ
// Формирует структуру с параметрами регистрации регистрации обработки в информационной базе
//
// Параметры:
//	ОбъектыНазначенияФормы - Массив - Массив строк имен объектов метаданных в формате: 
//					<ИмяКлассаОбъектаМетаданного>.[ * | <ИмяОбъектаМетаданных>]. 
//					или строка с именем объекта метаданных 
//	НаименованиеОбработки - строка - Наименование обработки, которым будет заполнено наименование элемента справочника по умолчанию.
//							Необязательно, по умолчанию синоним или представление объекта
//	Информация  - строка - Краткая информация или описание обработки.
//							Необязательно, по умолчанию комментарий объекта
//	Версия - строка - Версия обработки в формате “<старший номер>.<младший номер>” используется при загрузке обработок в информационную базу.
//
//
// Возвращаемое значение:
//		Структура
//
Функция ПолучитьПараметрыРегистрации(ОбъектыНазначенияФормы = Неопределено, НаименованиеОбработки = "", Информация = "", Версия = "1.0")
	
	
	Если ТипЗнч(ОбъектыНазначенияФормы) = Тип("Строка") Тогда
		ОбъектНазначенияФормы = ОбъектыНазначенияФормы;
		ОбъектыНазначенияФормы = Новый Массив;
		ОбъектыНазначенияФормы.Добавить(ОбъектНазначенияФормы);
	КонецЕсли; 
	
	ПараметрыРегистрации = Новый Структура;
	ПараметрыРегистрации.Вставить("Вид", "ПечатнаяФорма");
	ПараметрыРегистрации.Вставить("БезопасныйРежим", Истина);
	ПараметрыРегистрации.Вставить("Назначение", ОбъектыНазначенияФормы);
	
	Если Не ЗначениеЗаполнено(НаименованиеОбработки) Тогда
		НаименованиеОбработки = ЭтотОбъект.Метаданные().Представление();
	КонецЕсли; 
	ПараметрыРегистрации.Вставить("Наименование", НаименованиеОбработки);
	
	Если Не ЗначениеЗаполнено(Информация) Тогда
		Информация = ЭтотОбъект.Метаданные().Комментарий;
	КонецЕсли; 
	ПараметрыРегистрации.Вставить("Информация", Информация);
	
	ПараметрыРегистрации.Вставить("Версия", Версия);
	
	
	Возврат ПараметрыРегистрации;
	
	
КонецФункции

// Формирует таблицу значений с командами печати
//	
// Возвращаемое значение:
//		ТаблицаЗначений
//
Функция ПолучитьТаблицуКоманд()
	
	
	Команды = Новый ТаблицаЗначений;
	
	//Представление команды в пользовательском интерфейсе
	Команды.Колонки.Добавить("Представление", Новый ОписаниеТипов("Строка"));
	
	//Уникальный идентификатор команды или имя макета печати
	Команды.Колонки.Добавить("Идентификатор", Новый ОписаниеТипов("Строка"));
	
	//Способ вызова команды: "ОткрытиеФормы", "ВызовКлиентскогоМетода", "ВызовСерверногоМетода"
	// "ОткрытиеФормы" - применяется только для отчетов и дополнительных отчетов
	// "ВызовКлиентскогоМетода" - вызов процедуры Печать(), определённой в модуле формы обработки
	// "ВызовСерверногоМетода" - вызов процедуры Печать(), определённой в модуле объекта обработки
	Команды.Колонки.Добавить("Использование", Новый ОписаниеТипов("Строка"));
	
	//Показывать оповещение.
	//Если Истина, требуется показать оповещение при начале и при завершении работы обработки. 
	//Имеет смысл только при запуске обработки без открытия формы
	Команды.Колонки.Добавить("ПоказыватьОповещение", Новый ОписаниеТипов("Булево"));
	
	//Дополнительный модификатор команды. 
	//Используется для дополнительных обработок печатных форм на основе табличных макетов.
	//Для таких команд должен содержать строку ПечатьMXL
	Команды.Колонки.Добавить("Модификатор", Новый ОписаниеТипов("Строка"));
	
	
	Возврат Команды; 
КонецФункции

// Вспомогательная процедура.
//
Процедура ДобавитьКоманду(ТаблицаКоманд, Представление, Идентификатор, Использование = "ВызовСерверногоМетода", ПоказыватьОповещение = Ложь, Модификатор = "ПечатьMXL")
	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = Представление;
	НоваяКоманда.Идентификатор = Идентификатор;
	НоваяКоманда.Использование = Использование;
	НоваяКоманда.ПоказыватьОповещение = ПоказыватьОповещение;
	НоваяКоманда.Модификатор = Модификатор;      
КонецПроцедуры

#КонецОбласти  	

#Область ИНН

	ИННСанинбев					= "5020037784";	
	ИННПочтаРоссии				= "7724261610";	                               
	ИННКокаКола 				= "7701215046";
	ИННФерреро  				= "5044018861";
	ИННМВИДЕО  					= "7707548740";
	ИННМПК  					= "5029104266";
	ИННСпортмастер 				= "7728551528";
	ИННПолипластик				= "5021013384";
	ИННБалтика					= "7802849641";
	ИННСетраЛубрикатс 			= "7707240176";
	ИННКордиант 				= "7601001509";
	ИННАвтодизель 				= "7601000640";

#КонецОбласти