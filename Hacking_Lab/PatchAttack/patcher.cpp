#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <SFML/System.hpp>
#include <SFML/Audio.hpp>
#include <SFML/Window.hpp>
#include <SFML/Graphics.hpp>
#include "windows.h"


enum ER_CODES { MUSIC_ERROR = 1, FONT_ERROR = 2 };

const int TIME_FRAME = 2000;

const wchar_t* PHRASES[] = {
    L"Дешифрация SLM пакетов",
    L"Декодирование энкрипторов",
    L"Виртуализация сокетов",
    L"Имитация RISC запросов",
    L"Синхронизация системного контроллера"
};

const sf::Color BACKGROUND_COLOR = sf::Color::Black;
const sf::Color FOREGROUND_COLOR = sf::Color::Green;


class ProgressBar
{
private:
    sf::Clock clock;
    sf::RectangleShape border;
    sf::RectangleShape fill;
    float fill_velocity = 0;
    const int load_time = 10000;

public:
    ProgressBar(float x, float y, float width, float height)
    {
        border.setPosition(x, y);
        border.setOutlineColor(FOREGROUND_COLOR);
        border.setFillColor(BACKGROUND_COLOR);
        border.setOutlineThickness(4);
        border.setSize(sf::Vector2f(width, height));
        fill.setOutlineColor(FOREGROUND_COLOR);
        fill.setFillColor(FOREGROUND_COLOR);
        fill.setSize(sf::Vector2f(0, border.getSize().y));
        fill.setPosition(border.getPosition());
        fill_velocity = border.getSize().x / load_time;
        clock.restart();
    }

    void draw(sf::RenderWindow& window)
    {
        window.draw(border);
        window.draw(fill);
    }

    bool update()
    {
        sf::Time elapse = clock.getElapsedTime();
        float width = elapse.asMilliseconds() * fill_velocity;
        if (width >= border.getSize().x)
        {
            fill.setSize(border.getSize());
            return true;
        }
        fill.setSize(sf::Vector2f(width, border.getSize().y));
        return false;
    }
};

uint32_t CRC32_hash(char* buf, uint32_t len);

char* open_file(const char* fname, size_t* fsize);

sf::Text init_text(sf::Text& text, const wchar_t* string, int size, const sf::Font& font);

bool update_scene(sf::Text& text, ProgressBar& bar, sf::Clock& clock);

void center_text(sf::Text& text, int width);

bool patch();


int main()
{
    int windowHeight = 600;
    int windowWidth  = 800;
    sf::RenderWindow window(sf::VideoMode(windowWidth, windowHeight), "Keygen KolobAI", sf::Style::Default);

    sf::Music music;
    if (!music.openFromFile("music.wav"))
    {
        printf("Sorry guys. No music today :(\n");
        return MUSIC_ERROR;
    }
    sf::Font font;
    if (!font.loadFromFile("font.ttf"))
    {
        printf("ERROR loading font.\n");
        return FONT_ERROR;
    }
    sf::Text title;
    init_text(title, L"Вас приветсвует мастер патчер KolobAI", 22, font);
    sf::Text phrase;
    init_text(phrase, L"Взлом начнется прямо сейчас...", 18, font);
    title.setPosition(windowWidth / 8, windowHeight / 6);
    phrase.setPosition(2 * windowWidth / 8, 4 * windowHeight / 6);
    window.clear(BACKGROUND_COLOR);
    window.draw(title);
    window.draw(phrase);
    window.display();
    ProgressBar bar(windowWidth / 8, 5 * windowHeight / 6, 0.75 * windowWidth, 0.1 * windowHeight);
    music.play();
    sf::Clock clock;
    bool scene_over = false;
    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
            {
                music.stop();
                window.close();
            }
        }
        if (!scene_over)
        {
            scene_over = update_scene(phrase, bar, clock);
            center_text(phrase, windowWidth);
            window.clear(BACKGROUND_COLOR);
            bar.draw(window);
            window.draw(title);
            window.draw(phrase);
            window.display();
        }
    }
}

/**************************************************
Алгоритм CRC-32-IEEE 802.3
порождающий полином: 0x04C11DB7
перевернутый полином: 0xEDB88320
**************************************************/

uint32_t CRC32_hash(char* buf, uint32_t len)
{
    uint32_t crc = 0xFFFFFFFF;
    uint32_t val = 0;
    while(len--)
    {
        val = (crc ^ *buf++) & 0xFF;
        for(char i = 0; i < 8; i++)
            val = val & 1 ? (val >> 1) ^ 0xEDB88320 : val >> 1;
        crc = val ^ crc >> 8;
    }
    return crc ^ 0xFFFFFFFF;
}


char* open_file(const char* fname, size_t* fsize)
{
    FILE* exec = fopen(fname, "rb");
    fseek(exec, 0, SEEK_END);
    *fsize = ftell(exec);
    char* buffer = (char*)calloc(*fsize, sizeof(buffer[0]));
    fseek(exec, 0, SEEK_SET);
    fread(buffer, sizeof(buffer[0]), *fsize, exec);
    fclose(exec);
    return buffer;
}


sf::Text init_text(sf::Text& text, const wchar_t* string, int size, const sf::Font& font)
{
    text.setFont(font);
    text.setString(string);
    text.setCharacterSize(size);
    text.setFillColor(FOREGROUND_COLOR);
    return text;
}


bool update_scene(sf::Text& text, ProgressBar& bar, sf::Clock& clock)
{
    if (bar.update())
    {
        patch() ? text.setString(L"Готово. Не надо благодарностей.") : text.setString(L"Неправильный файл.");
        return true;
    }
    sf::Time elapsed = clock.getElapsedTime();
    sf::Time delay = sf::milliseconds(TIME_FRAME);
    if (elapsed > delay)
    {
        clock.restart();
        text.setString(PHRASES[rand() % 5]);
    }
    return false;
}


void center_text(sf::Text& text, int width)
{
    sf::FloatRect bounds = text.getGlobalBounds();
    float x_offset = (float)(width - bounds.width) / 2;
    text.setPosition(x_offset, text.getPosition().y);
}


bool patch()
{
    int len_byte_pos = 0x5C;
    int jne_byte_pos = 0x5D;
    int cmp_byte_pos = 0x33;
    char size_byte = 0x09;
    char jne_byte  = 0x75;
    char cmp_byte  = 0xDA;
    size_t fsize = 0;
    uint32_t correct_hash = 0x53CDC14C;
    char* buffer = open_file("PATCH.COM", &fsize);
    bool correct = correct_hash == CRC32_hash(buffer, fsize);
    correct = correct && buffer[len_byte_pos] == size_byte;
    correct = correct && buffer[jne_byte_pos] == jne_byte;
    correct = correct && buffer[cmp_byte_pos] == cmp_byte;
    if (!correct)
    {
        fprintf(stderr, "Trying to patch invalid file. File already modified or incorrect file chosen.\n");
        return false;
    }
    char bx_byte = 0xDB;
    char jb_byte = 0x72;
    buffer[len_byte_pos] = 0;
    buffer[jne_byte_pos] = jb_byte;
    buffer[cmp_byte_pos] = bx_byte;
    FILE* exec = fopen("PATCH.COM", "wb");
    fwrite(buffer, sizeof(buffer[0]), fsize, exec);
    fclose(exec);
    free(buffer);
    return true;
}
