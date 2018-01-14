#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>
#include <cstdio>
#include <iostream>
#include <iomanip>


extern "C"
{
    void parabola(sf::Uint8 * memoryBlock, int width, int height, float a, float p, float q, float range); // assembly function
}

extern "C"
void shout(int what)
{
	printf("Shout: %d!\n", what);
}

extern "C"
void shout2(float what)
{
	printf("Shout: %f!\n", what);
}

sf::Text prepareEquationText(float a, float p, float q, int width, int height, sf::Font& font)
{
	std::stringstream text;
	text << "y = " << std::setprecision(2) << std::fixed << std::showpos << a << " (x " << p << ")^2 " << q;
	
	sf::Text returnedText(text.str(), font);
	returnedText.setCharacterSize(12);
	sf::FloatRect textRect = returnedText.getLocalBounds();
	returnedText.setOrigin(textRect.left + textRect.width/2.0f, textRect.top  + textRect.height/2.0f);
	returnedText.setPosition(width/2, height - 5 - 11);
	
	return returnedText;
}

int main()
{
    const unsigned int width = 600;
    const unsigned int height = 600;
    const float range = 4.0;
	const float scrollDelta = 0.2;
	
	float p = 0.0;
	float q = 0.0;
	float a = 1.0;
	
    sf::RenderWindow window(sf::VideoMode(width, height), "x86 - parabola", sf::Style::Titlebar | sf::Style::Close);
    sf::Uint8 * pixels = new sf::Uint8[width * height * 4];

    sf::Texture texture;
    texture.create(width, height);
    sf::Sprite sprite(texture);

	sf::Font font;
	font.loadFromFile("arial.ttf");
	sf::Text helpText("LMB - generate parabola\nRMB - negate the slope\nMouse wheel - change the slope", font);
	helpText.setCharacterSize(11);
	helpText.setPosition(5, 5);
	sf::Text equationText("", font);
	
	window.clear();
	parabola(pixels, width, height, a, p , q, range);
	texture.update(pixels);
    window.draw(sprite);
	window.draw(helpText);
	equationText = prepareEquationText(a, p, q, width, height, font);
	window.draw(equationText);
    window.display();

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
            else if(event.type == sf::Event::MouseButtonPressed)
            {
				if(event.mouseButton.button == sf::Mouse::Left)
				{				
					p = event.mouseButton.x;
					p = p - width / 2;
					p = p / (width / 2);
					p = p * range;
					
					q = event.mouseButton.y;
					q = (height / 2) - q;
					q = q / (height / 2);
					q = q * range;
				}
				else if(event.mouseButton.button == sf::Mouse::Right)
				{
					a = -a;
				}
				
                window.clear();
                parabola(pixels, width, height,	a, p, q, range);
                texture.update(pixels);
                window.draw(sprite);
				window.draw(helpText);
				equationText = prepareEquationText(a, p, q, width, height, font);
				window.draw(equationText);
                window.display();
            }
			else if (event.type == sf::Event::MouseWheelScrolled)
			{
				if (event.mouseWheelScroll.wheel == sf::Mouse::VerticalWheel)
				{
					a += event.mouseWheelScroll.delta * scrollDelta;
					window.clear();
					parabola(pixels, width, height,	a, p, q, range);
					texture.update(pixels);
					window.draw(sprite);
					window.draw(helpText);
					equationText = prepareEquationText(a, p, q, width, height, font);
					window.draw(equationText);
					window.display();
				}
			}
        }
    }

    delete [] pixels;
    return 0;
}
