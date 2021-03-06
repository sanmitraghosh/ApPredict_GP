close all
clear all
clc

x = -pi:.1:pi;
y = sin(x);
p = plot(x,y)
set(gca,'XTick',-pi:pi/2:pi)
set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'})
xlabel('-\pi \leq \Theta \leq \pi')
ylabel('sin(\Theta)')
title('Simulation Results')
text(-pi/4,sin(-pi/4),'\leftarrow sin(-\pi\div4)',...
     'HorizontalAlignment','left')
set(p,'Color','red','LineWidth',2)

latex_fig(10, 2.5, 1.77)
openfig('surfActive4D.fig')

set(findall(gcf,'-property','FontSize'),'FontSize',11)
font_size=11;
f_width =2.5;f_height=2;
font_rate=10/font_size;
set(gcf,'Position',[100   200   round(f_width*font_rate*144)   round(f_height*font_rate*144)])
set(legend1,...
    'Position',[0.328982896120446 0.0367826714741751 0.374303675110236 0.0213358065801117],...
    'Orientation','horizontal');


a=get(gcf,'Position');
iw=(a(3)/144);
ih=(a(4)/144);
get(gcf,'Legend')
t=linspace(0,10,100)
a=1+exp(-t)'
plot(t,a)
hold on
b=circshift(a,20)
plot(t,b)