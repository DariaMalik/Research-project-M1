% Projet IRP - M1 Signal Imagerie
% Université Paul Sabatier (Toulouse)
% CERE Cassandra - MALIK Daria - TABOUCHE Massinissa

% ---------------------------------------------------------------------------------
% |                 détection des "evenements" dans les images                    |
% |                       issues des vidéos ultra rapides                         |
% |   acquises lors des experimentations de treblement de terre en laboratoire    |
% ---------------------------------------------------------------------------------


% ========================================================================
% ============================ charger images ============================

% charger l'image
im_brute = load('20200115_4_04_mm1.mat');
%im_brute = load('20200130_3_9_mm1');
%im_brute = load('20200130_5_10_mm1');

im_brute = im_brute.mm1';

% prendre une partie
im_brute = im_brute(90000:145000, 600:1100);

[Nligne, Ncol] = size(im_brute);

% soustraire la 1ere ligne ou colonne
im_brute_ligne = im_brute - repmat(im_brute(1,:),size(im_brute,1),1);

disp('Chargement image fini')

%% =======================================================================
% ======================= filtrer les colonnnes dans fft =================

num_col = 250;

fft_col = fft(im_brute,[],1);

% mettre à 0 les hautes fréquences dans chaque fft
seuil_filtre_col = 50;

% filtrer les colonnes
filtre_col = fft_col;
filtre_col(seuil_filtre_col+1:end-seuil_filtre_col,:) = 0;

% fft inverse
filtre_col = real(ifft(filtre_col,[],1));

figure
hold on
plot(im_brute(:,num_col))
plot(filtre_col(:,num_col), 'g', 'LineWidth', 2)
title('\fontsize{20}intensité d''une colonne')
legend('\fontsize{12}avant filtrage','\fontsize{12}après filtrage')

% soustraire la première ligne
filtre_col_ligne = filtre_col - repmat(filtre_col(1,:),size(filtre_col,1),1);

figure
colormap gray
subplot(131)
imagesc(im_brute)
title('\fontsize{13}partie d''image brute')
subplot(132)
imagesc(im_brute_ligne)
title('\fontsize{13} - 1ère ligne')
subplot(133)
imagesc(filtre_col_ligne)
title('\fontsize{13}colonnes filtrées - 1ère ligne')
colorbar

%% =======================================================================
% ======================== detection de la courbe ========================

% trouver les minimas et maximas dans les colonnes
[~,ind] = min(filtre_col_ligne);
[~,ind1] = max(filtre_col_ligne);

figure
colormap gray
subplot(121)
imagesc(filtre_col_ligne)
title('\fontsize{13}Colonnes filtrées - 1ère ligne')
subplot(122)
imagesc(filtre_col_ligne)
hold on
plot(1:501, ind, 'g*')
plot(1:501, ind1, 'm*')
legend('\fontsize{13}minima','\fontsize{13}maxima')

% h = zeros(2, 1);
% h(1) = plot(NaN,NaN,'g*', 'markersize', 10);
% h(2) = plot(NaN,NaN,'m*', 'markersize', 10);
% legend(h, '\fontsize{13}minima','\fontsize{13}maxima')

%% =======================================================================
% =========================== filtrer les points =========================

% [test,S1,S2] = ischange(ind);
% segline = S1.*(1:Ncol) + S2;
% hold on
% plot(ind)
% plot(segline)

% ------------------------- variances des colonnes -----------------------

% var_col = var(filtre_col_ligne);
% var_col_moy = mean(var_col);
% 
% figure
% colormap gray
% imagesc(filtre_col_ligne)
% hold on
% yyaxis right
% plot(var_col, 'y', 'LineWidth', 2)
% plot([1, Ncol], [var_col_moy, var_col_moy], 'g-', 'LineWidth', 2)
% legend('\fontsize{15}variance des colonnes', '\fontsize{15}variance moyenne')

% ----------------- différence entre deux points successifs --------------

figure
colormap gray
imagesc(filtre_col_ligne)
hold on

test = zeros(size(ind));
x = zeros(size(ind));

for k = 1:Ncol-1
    if (abs(ind(k+1)-ind(k))<0.35*Ncol && abs(ind(k+1)-ind(k))>0.2*Ncol) 
        test(k) = ind(k);
        test(k+1) = ind(k+1);
        x(k) = k;
        x(k+1) = k+1;
    end
end

test1 = nonzeros(test);
x1 = find(test);

plot(x1, test1, 'gd')

test = zeros(size(ind1));
x = zeros(size(ind1));

for k = 1:Ncol-1
    if (abs(ind(k+1)-ind(k))<0.4*Ncol && abs(ind(k+1)-ind(k))>0.1*Ncol) 
        test(k) = ind1(k);
        test(k+1) = ind1(k+1);
        x(k) = k;
        x(k+1) = k+1;
    end
end

test1 = nonzeros(test);
x1 = find(test);

plot(x1, test1, 'yd')

title('\fontsize{17}points conservés si la difference entre les 2 points voisins < certaine distance')




