unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus, Grids;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;



implementation

{$R *.lfm}

// Наши собственные типы данных, используемые в приложении
Type

  // тип для отдельно взятого студена
  Stud = Record
    No       : integer;     // Номер (его ID)
    Name     : string[12];  // Имя
    Gr       : string[8];   // Группа
    o1,o2,o3 : integer;     // Оценки
  end;

// Глобальные переменные
var sf: string; // Спецификация файла - его полное имя


//Собственные процедуры и функции

{Параметры таблицы по умолчанию}
procedure TabForFile;
var i: integer;
begin
  // Используем менеджер контекста для сокращения,
  // чтобы слишком часто не писать длинную строчку для доступа к атрибуту
  // По типу Form1.Stringgrid1.attr, как бы считаем что мы внутри StringGrid1
  // И Можем не указывать полное имя, чтобы поменять что-то внутри
  with Form1.StringGrid1 do
  begin

    ColCount := 6;  // Число столбцов  для (1)номера, (2)имени, (3)групы и (4-6)оценок одного студента
    RowCount := 50; // Количество строк

    // Устанавливаем ширину отдельных ячеек, т.к. для, например, имени и оценки нужно разное число полей
    // Столбцы (как почти и всё) нумеруются с нуля!!!
    ColWidths[0] := 20;  // на Номер студента 20 пикселей
    ColWidths[1] := 120; // на Фамилию - 120
    ColWidths[2] := 80;  // Группа
    ColWidths[3] := 40;  // Маленкое поле для Оценки 1
    ColWidths[4] := 40;  // Оц 2
    ColWidths[5] := 40;  // Оц 3

    // Заполняем заголовок нашей таблицы
    Cells[0,0] := '№';
    Cells[1,0] := 'Фамилия';
    Cells[2,0] := 'Группа';
    Cells[3,0] := 'Оц 1';
    Cells[4,0] := 'Оц 2';
    Cells[5,0] := 'Оц 3';

    // Теперь устанавливаем ширину всей таблицы
    width := 25; // дополнительные 25 пикселей на полосу прокрути и прочее
    for i:=0 to ColCount-1 do
      width:= width + ColWidths[i]; // Прибавляем ширину i-го столбца к общей ширине таблицы

  end;
end;

{Процедура очищения таблицы (без заголовка)}
// StringGrid1.Clean - очищает всю таблицу
// Процедура НЕОБЯЗАТЕЛЬНАЯ, можно спокойно писать каждый раз TabForFile -
// Устанавливать параметры таблицы по умолчанию
Procedure ClearTab;
var i, j: integer;
begin
  with Form1.StringGrid1 do
    // Перебираем все строки кроме заголока(i=0)
    for i:= 1 to RowCount -1 do
      // Не имеет смысла очищать строку если она пустая
      if (CellS[0,i] <>'') then
        // Перебираем все столбцы
        for j:=0 to ColCount-1 do
          Cells[j,i] :=''; // 'обнуляем'нужные ячейки
end;

{Сохранить данные о студентах в файл}
procedure SaveToFileOfStud;
var f: file of stud;
    s: stud; // Переменная для СЧИТЫВАНИЯ ИЗ StringGrid1 одного студента и записи его в файл
    i: integer;
begin
  // Здесь считаем что sf - не пустая строка, то есть имя файла уже задано

  // Стандартные действия по подготовке к ЗАПИСИ в файл
  AssignFile(f, sf);
  Rewrite(f);

  with Form1.StringGrid1 do
    // Перебираем строки
    // Причом начинаем с 1, тк на 0 месте строка ЗАГОЛОВКА
    for i:=1 to RowCount -1 do
      // Перебираем НЕ ПУСТЫЕ строки
      if CellS[0,i] <>'' then
      begin
        // Записываем в s нужные поля, кто он, где учится, как учится и тп
        s.No   := StrToInt(Cells[0,i]); // Заполняем Номер студента
        s.Name := Cells[1,i];           // Получаем  Фамилию студента
        s.Gr   := Cells[2,i];           // Группа студента
        // Оценки
        s.o1   := StrToInt(Cells[3,i]);
        s.o2   := StrToInt(Cells[4,i]);
        s.o3   := StrToInt(Cells[5,i]);

        // Полученного студента записываем в файл
        write(f,s);
      end;

// в самом конце закрываем файл
CloseFile(f);
end;

{Загрузить данные о студентах в таблицу из файла}
procedure LoadFromFileOfStud;
var f: file of Stud;
    s: stud; // Переменная для ЗАПИСИ В StringGrid1 одного студента и считывания его из файла
    i: integer;
begin

  // Подготавливаем файл к ЧТЕНИЮ
  AssignFile(f, sf);
  Reset(f);

  with Form1.StringGrid1 do
  // Опять же начинаем с еденицы, чтобы не задеть заголовок
  for i:=1 to filesize(f) do
  begin

    // Считываем одного студента
    read(f,s);

    // И записываем данные о нём в таблицу
    Cells[0,i]:= IntToStr(s.No);  // Его Номер
    Cells[1,i]:= s.Name;          // Фамилия
    Cells[2,i]:= s.Gr;            // Группа
    Cells[3,i]:= IntToStr(s.o1);
    Cells[4,i]:= IntToStr(s.o2);   {И оценки}
    Cells[5,i]:= IntToStr(s.o3);
  end;

// и в самом конце закрываем файл
closefile(f);
end;


// Процедуры-Обработчики на форме
{ TForm1 }

{Особые действия при открытии программы}
procedure TForm1.FormCreate(Sender: TObject);
begin
  TabForFile; // Устанавливаем параметры таблицы по умолчанию
  // Добавляем оциию редактирования содержимого таблицы
  StringGrid1.Options:=StringGrid1.Options + [goEditing];
  StringGrid1.FixedCols:=0; //Чтобы можно было редактировать номера
  StringGrid1.Modified := False;
  sf := '';   // Никакого файла мы ещё не открывали

  // Каталоги для сохраненияи открытия по умочанию (Папка проекта)
  OpenDialog1.InitialDir:='';
  SaveDialog1.InitialDir:='';
end;

{Создать}
procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  ClearTab;  // Очищаем таблицу своей процедурой, что равносильно изменению Таблицы
  StringGrid1.Modified:= False; // Таблица не была изменена
  sf:='';     // А у файла нет ещё имени
  Form1.Caption:= 'Form1';
end;

{Открыть}
procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  // диалог сохранинея файла
  if StringGrid1.Modified then
    case MessageDlg('Текст был изменён' + #13 + 'Сохранить его?',
                    mtConfirmation,[mbYes, mbNo, mbCancel],0) of
      mrYes   : MenuItem5Click(self); // Сохраняем файл
      mrNo    : ;                     // Ничего не делаем
      mrCancel: Exit;                 // выходим из процедуры {Открыть}
    end;

  // Если дилог открытия файла завершился нормально,
  // То есть его не закрыли и не нажали cancel
  // То есть юзер выбрал нужный ему файл и нажал ОК
  if openDialog1.Execute then
  begin
    sf:=OpenDialog1.FileName;     // Извлекаем имя файла из этого диалога
    LoadFromFileOfStud;           // Выводим его в StringGrid1
    StringGrid1.Modified:=False;  // Что равносильно его изменению, но мы же не изменяли файл
    Form1.Caption:='Form1 ' + sf; // В заголовок окна выводим имя файла
  end;
end;

{Закрыть}
procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  // Стандартных диалог сохранения файла
  // Если таблица была изменена
  if StringGrid1.Modified then
    // Стандартное окно Сообщения
    case MessageDlg('Данные о студентах были изменены' + #13 + 'Сохранить их?',
                                  mtConfirmation,[mbYes, mbNo, mbCancel],0) of
      mrYes: MenuItem5Click(self); // Сохраняем файл
      mrNo:;                       // Ничего не делаем
      mrCancel: Exit; // Выходим из окна сообщения, и возвращаемся к редактированию таблицы(действия ниже выполняться не будут)
    end;

  // Если мы НЕ вишли через 'Cancel', то совершаем стандартные действия
  ClearTab;  // Очищаем таблицу процедурой собственного производства  и тд
  StringGrid1.Modified:= False;
  sf:='';
  Form1.Caption:= 'Form1';
end;

{Сохранить}
procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  // Исли имя файла не задано то вызываем Окно {сохранить как}
  if sf = '' then MenuItem6Click(self)
  else  // Иначе, то есть имя файла уже установлено
  begin
    SaveToFileOfStud; // Сразу сохраняем его на диск
    StringGrid1.Modified:= False;  // Содержание устанавливаем не изменённым, тк сохранили всё на диск
  end;
end;

{Сохранить как}
procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  // Если диалог сохранения прошёл хорошо
  if SaveDialog1.Execute then
  begin
    sf:= SaveDialog1.FileName; // Извлекаем имя файла
    SaveToFileOfStud;          // Используя нашу процедуру, сохраняем содержимое таблицы в файл

    StringGrid1.Modified := False; // Содержимое в таблице соответсвует файлу на диске
    Form1.Caption:= 'Form1 ' + sf; // Устанавливаем заголовок приложения с именем файла
  end;
end;

{Выход}
procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  // Сообщение: Сохранить ли именённый файл
  if StringGrid1.Modified then
    case MessageDlg('Таблица была изменена' + #13 + 'Сохранить её?',
                       mtConfirmation,[mbYes, mbNo, mbCancel],0) of
      mrYes   : MenuItem5Click(self);  // Сохраняем изменения в файл
      mrNo    : ;                      // Ничего не делаем
      mrCancel: Exit;                  // Возвращаемся к редактирования таблицы
    end;

  // Закрываем приложение
  Close;
end;


// Обработка

{Обратить порядок}
procedure TForm1.MenuItem9Click(Sender: TObject);
var f: file of Stud; // файл со студентами
    n: integer; // число студентов в таблице
    i: integer; // для перебора студентов
    s: Stud; // студент записываемый в файл
begin
  // Здесь считаем что пользователь уже открыл файл в табличном редакторе
  // то есть sf - не пустая

  // Очищаем файл и открываем его на ЗАПИСЬ
  AssignFile(f, sf);
  Rewrite(f);

  // Сначала нужно узнать сколько студентов в таблице
  // Поэтому обходим студентов в таблице до тех пор
  // пока строки НЕ пустые - если обнаруживаем, что строка пустая - то
  // дальше студентов нет

  // Будем проверять n-ую строку
  // и начнём с 1 -ой
  // Не с 0 - так как нулевая строка - это ЗАГОЛОВОК
  n := 1;
  // Достаточно проверять только ПЕРЫЙ(нулевой) столбец n-ой строки
  // Если он пустой - то и вся строка пустая
  while (StringGrid1.Cells[0, n] <> '') do
    n := n + 1;

  // После цикла получаем что строка с индексом n - пустая
  // Теперь чтобы пулучить индекс ПОСЛЕДНЕЙ НЕ пустой строки - вичитаем 1
  // то есть предыдущая строка - не пустая
  n:= n -1;

  // Начиная с этой строки в обратном порядке записываем студентов типизированный файл
  for i:= n downto 1 do
  begin
    // собираем студента из таблицы в запись типа Stud - переменную s
    // Для удобства используем with, чтобы меньше писать StringGrid1.Cells
    // а просто писать Cells
    with StringGrid1 do
    begin
      // Записываем в s нужные поля, кто он, где учится, как учится и тп
      s.No   := StrToInt(Cells[0,i]); // Заполняем Номер студента
      s.Name := Cells[1,i];           // Получаем  Фамилию студента
      s.Gr   := Cells[2,i];           // Группа студента
      // Оценки
      s.o1   := StrToInt(Cells[3,i]);
      s.o2   := StrToInt(Cells[4,i]);
      s.o3   := StrToInt(Cells[5,i]);
    end;

    // Теперь студента s можно записать в файл
    write(f, s);
  end;
  // Обошли всех студентов и всех записали в файл - надо закрыть файл
  CloseFile(f);

  // Для удобства выведем изменённый файл в таблицу
  LoadFromFileOfStud;

  // Мы изменяли таблицу - но сейчас файл на диске соответствует
  // записям на диске
  StringGrid1.Modified := False;

end;

// СОБСТВЕННАЯ логическая функция
// check - глагол - проверить
{Соответствует ли строка маске}
// эта функция поддерживает сложную маску с несколькими звёздочками
// например *ab*cd*
function check_mask(maska: string; s: string): boolean;
// переменная, куда будем записывать результат - её значение возвращет функция
var res: boolean;
    i_m: integer; // индекс символа в МАСКЕ
    i_s: integer; // индекс символа в СТРОКЕ
    i_star: integer; // Индекс звёздочки в МАСКЕ
    i_s_after: integer; // индекс ПЕРВОГО символа строки = символу маски после *
begin
  i_m := 1;
  i_s := 1;
  i_star := 0;
  i_s_after := 0;
  res:= False; // цикл может иногда отработать и не дать значение переменной
  // Обходим символы маски
  while(i_m <= Length(maska)) do
  begin
    // 1-ый случай символ = '*'
    if (maska[i_m] = '*') then
    begin
      // Запоминнаем где у нас расположена звёздочка в маске
      i_star := i_m;

      // если мы дошли до сюда, то есть всё это время строка была верна маске
      // и * расположена в конце маски то можно завершать цикл, потому что
      // даже если в строке s есть символы, то * их как бы их убирает
      // она обозначает 0 или бесконечно много символов
      // Маска заканчивается * и мы дошли до сюда, то дальше смотреть
      // строку s не нужно, она полность СООТВЕТСВУЕТ МАСКЕ
      if (i_m = Length(maska)) then
      begin
        res := True; // Говорим что строка соответствует маске
        break;       // выходим из цикла
      end;

      // Звёздочка не в конце МАСКИ
      // Тогда нужно узнать какой символ в маске идёт за звёздочкой
      i_m := i_m + 1; // переходим на один символ вперёд в МАСКЕ
      // Дальше перебираем строку s до тех пор пока символы
      // в маске и в строке не совпадут или строка закончится
      while(i_s <= Length(s)) and (s[i_s] <> maska[i_m]) do
        i_s := i_s + 1;

      // мы вышли из цикла, следовательно нашли или не нашли такой символ

      // если строка закончилась, то мы символа не нашли
      // а значит строка s  НЕ СООТВЕТСТВУЕТ маске
      if (i_s > Length(s)) then
      begin
        res:= False;  // строка не по маске
        break;        // выходим из цикла
      end;

      // Сохраняем индекс символа = символу маски
      // вдруг мы нашли не тот символ
      // в строке ещё может быть много символов = символу маски
      // если этот не подойдёт, мы просто занаво будем искать этот символ
      // но поиск уже вести после этого - ПЛОХОГО символа
      // а не с начала строки, ведь мы так опять попадём на этот символ
      i_s_after := i_s;
    end
    else
    // если мы здесь то символ маски не равен '*'
    // 2-ой случай
    begin
      // Тогда символы маски должны быть равными символам в строке
      // Если это так, то
      if(maska[i_m] = s[i_s]) then
      begin
        // Проверяем вдруг мы дошли до конца строки
        // и до конца маски
        // значит СТРОКА ПОЛНОСТЬЮ соответствует МАСКЕ
        if (i_s = Length(s)) and (i_m = Length(maska)) then
        begin
          res := True; // говорим, что соответствует
          break;       // и выходим из цикла перебора символов маски
        end;

        // если мы не дошли до конца маски и строки
        // то переходим к следующим символам в этих строках
        i_s := i_s + 1;
        i_m := i_m + 1;



        if (i_m > Length(maska)) and (i_s <= Length(s)) and (i_star <> 0) then
        begin
          // возвращаемся к звёздочке в маске
          i_m := i_star;
          // индекс в маске ставим после ЛОЖНО найденного символа
          i_s:= i_s_after + 1;
          // Дальше опять возвращаемся в БОЛЬШОЙ цикл перебора символов маски
        end;

        // после этого опять начинается БОЛЬШОЙ цикл while
        // перебора символов маски
      end
      else
      begin
        // Здесь символы маски и строки не равны,и причом символ маски не равен '*'
        // Поэтому возможны два варианта
        // 1-ый : строка не соответствует маске
        // 2-ой : при передыдущем переборе звёздочки, когда мы пропускали символы
        //        мы не до конца проверели строку, вдруг там есть ЕЩЁ ОДИН СИМВОЛ,
        //        стоящий * в маске

        // Сначала проверим второй вариант
        // то есть до этого была звёздочка
        if (i_star <> 0) then
        begin
          // возвращаемся к звёздочке в маске
          i_m := i_star;
          // индекс в маске ставим после ЛОЖНО найденного символа
          i_s:= i_s_after + 1;
          // Дальше опять возвращаемся в БОЛЬШОЙ цикл перебора символов маски
        end
        else
        // Если звёздочки не было, то строка НЕ СООТВЕТствует маске
        begin
          res:= False;   // Говорим, что не соответствует
          break;         // выходим из цикла - дальше проверять не имеет смысла
        end;

      end;

    end;

  end;

  // то что возвращает функция
  check_mask := res;
end;


{Выбор по маске}
procedure TForm1.MenuItem10Click(Sender: TObject);
var maska: string; // Маска фамилии студента
    f: file of Stud; // файл со студентами
    s: Stud; // Студет считываемый из файла
    i: integer; // счётчик студентов соответствующих маске - которые записываем в таблицу
begin
  // Предполагаем, что мы уже открыли в редакторе файл
  // то есть sf - известно

  // открываем файл с записями о студентах на ЧТЕНИЕ
  AssignFile(f, sf);
  Reset(f);

  // Получаем маску фамилии
  maska := inputbox('Ввод маски для фамилии', 'Используйте "*"', 'S*o*v');

  // Очищаем StringGrid1 для записи туда студентов
  ClearTab;

  // Сначала считаем что в файле нет студентов соответствующих маске
  // если появится такой студент то увеличим этот счётчик
  i:= 0;
  // Считываем записи из файла до его конца
  while(not EOF(f)) do
  begin
    // Считали одного студента
    read(f, s);

    // если фамилиия студнта соответствует маске то выводим его в таблицу
    if check_mask(maska, s.Name) then
    begin
      // Увеличиваем счётчик студентов соответствующих маске
      i := i + 1;
      // записываем студента в i-ую строку
      // Используем with, чтобы меньше писать StringGrid1
      with StringGrid1 do
      begin
        // И записываем данные о нём в таблицу
        Cells[0,i]:= IntToStr(s.No);  // Его Номер
        Cells[1,i]:= s.Name;          // Фамилия
        Cells[2,i]:= s.Gr;            // Группа
        Cells[3,i]:= IntToStr(s.o1);
        Cells[4,i]:= IntToStr(s.o2);   {И оценки}
        Cells[5,i]:= IntToStr(s.o3);
      end;
    end;
  end;
  // Завершили чтение студентов из файла - надо его закрыть
  CloseFile(f);

  // Мы изменяли таблицу, но файл не трогали
  StringGrid1.Modified := False;
end;



end.
