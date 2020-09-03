
> This repo contains my study DOS projects.  

### Гайд по установке сборки ded32.ru на Linux  
* Установите обычный DosBox с помощью `sudo apt-get install dosbox`
* Далее запускаем досбокс с помощью `dosbox` и создаем (*монтируем*) диск с помощью команды `mount <S> <PATH>` где  
 `<S>` - название диска (например `S`).  
 `<PATH>` - полный путь до папки в вашем линуксе, в которой вы храните файлы для досбокса (.com, .bat и прочее).  
 * Далее переходим на созданный диск с помощью `S:`. Чтобы проверить что все сработало введите `dir`, должно вывести список файлов в `<PATH>`.

 Теперь вы можете запускать файлы с расширением .com или .bat, поместив их в `<PATH>`.  
 Чтобы настроить компилятор *tasm*, дебаггер *td*, и *Far Manager* нужно найти бинарники этих приложений в исходной папке сборки, и (*аккуратно*) перенести их в `<PATH>`. Данная задача предоставляется читателю в качестве упражнения (потому что я сам не пробовал делать) :)