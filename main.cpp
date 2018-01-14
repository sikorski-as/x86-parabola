#include <SFML/Graphics.hpp>
#include <SFML/System.hpp>
#include <cstdio>
#include <iostream>


extern "C"
{
    void parabola(sf::Uint8 * memoryBlock, int width, int height, float a, float p, float q, float range); // assembly function
}

/*
sf::Vector2f transform(int x, int y, int width, int height)
{
	
	
	return sf::Vector2f();
}
*/

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

int main()
{
    const unsigned int width = 600;
    const unsigned int height = 600;
    const float range = 1.0;
	const float scrollDelta = 0.2;
	
	float p = 0.0;
	float q = 0.0;
	float a = 1.0;
	
    sf::RenderWindow window(sf::VideoMode(width, height), "x86 - parabola");
    sf::Uint8 * pixels = new sf::Uint8[width * height * 4];

    sf::Texture texture;
    texture.create(width, height);
    sf::Sprite sprite(texture);
	
	parabola(pixels, width, height, a, p , q, range);
	window.clear();
	texture.update(pixels);
    window.draw(sprite);
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
					std::cout << "mouse x: " << event.mouseButton.x << std::endl;
					std::cout << "mouse y: " << event.mouseButton.y << std::endl;
					p = static_cast<float>(event.mouseButton.x - width / 2) * range / (width / 2);
					std::cout << "p = " << p << std::endl;
					q = static_cast<float>(event.mouseButton.y - height / 2) / (height / 2) * range;
					std::cout << "q = " << q << std::endl;
				}
				else if(event.mouseButton.button == sf::Mouse::Right)
				{
					a = -a;
				}
				
                window.clear();
                parabola(pixels, width, height,	a, p, q, range);
                texture.update(pixels);
                window.draw(sprite);
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
					window.display();
				}
			}
        }
    }

    delete [] pixels;
    return 0;
}
