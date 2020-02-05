#include "stm32f4xx.h"

int main (void)
{
	RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
	GPIOA->MODER = GPIO_MODER_MODE5_0;
	GPIOA->OSPEEDR = GPIO_OSPEEDR_OSPEED5_1 | GPIO_OSPEEDR_OSPEED5_0;
	uint32_t i, n = 1000000;
	while (1)
	{
		GPIOA->BSRR |= GPIO_BSRR_BS5;
		i = 0;
		while (i++ < n);
		GPIOA->BSRR |= GPIO_BRR_BR5;
		i = 0;
		while (i++ < n);
	}
}