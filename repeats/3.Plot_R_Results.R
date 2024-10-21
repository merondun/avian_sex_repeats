# Repeat results
setwd('/dss/dsslegfs01/pr53da/pr53da-dss-0021/projects/2023__Comparative_W/repeats/earlgrey/collated_outputs')
library(tidyverse)
library(RColorBrewer)

# Import species order
order <- read_tsv('../Species.list',col_names = F)

# Import high level proportions
high_level <- read_tsv('highLevelCounts.txt')
names(high_level) <- c('Classification','Coverage','Count','Proportion','Gen','Distinct_Classifications','Chromosome','Species')
high_level$Species <- factor(high_level$Species,levels=order$X1)

# For each species, we need to add the NON-REPEATS, this can be done by summing the proportions and then subtracting one 
non_repeat <- high_level %>% 
  group_by(Species,Chromosome) %>% 
  summarize(Proportion = 1-(sum(Proportion)),
            Classification = "Non Repeat",
            Coverage=NA,Count=NA,Gen=NA,Distinct_Classifications=NA)

high_level_full <- rbind(high_level,non_repeat)
high_level_full$Classification = factor(high_level_full$Classification,levels=c('DNA','LTR','LINE','SINE','Penelope','Rolling Circle','Other (Simple Repeat, Microsatellite, RNA)','Unclassified','Non Repeat'))

# Plot 
high_level_plot <- high_level_full %>% 
  ggplot(aes(y=Species,x=Proportion,fill=Classification))+
  geom_bar(stat='identity')+
  facet_grid(.~Chromosome,scales='free')+
  theme_bw(base_size=7)+
  scale_fill_manual(values=c(brewer.pal(8,'Paired'),'grey95'))

pdf('high_level_plot.pdf',height=6,width=7)
high_level_plot
dev.off()

# Divergence summaries
divs <- read_tsv('divergence_summary.txt')
divs <- divs %>% dplyr::rename(Species = Archilochus_colubris, Chromosome = Z)
divs$Species <- factor(divs$Species,levels=order$X1)
divs$subclass = factor(divs$subclass,levels=c('DNA','LTR','LINE','SINE','PLE','RC','Other','Unknown'))

# Histograms
div_histo_plot <- divs %>% 
  filter(!grepl('Other|Unknown',subclass)) %>% 
  ggplot(aes(x=mean_div,fill=Species))+
  geom_histogram(alpha=0.2)+
  facet_grid(subclass~Chromosome,scales='free')+
  theme_bw(base_size=7)+
  xlab('Mean Kimura Distance')+
  theme(legend.position='none')

pdf('divergence_histo_plot.pdf',height=4,width=4)
div_histo_plot
dev.off()

# Show specific species
div_plot <- divs %>% filter(grepl('LTR|SINE|LINE|DNA',subclass)) %>% 
  ggplot(aes(y=Species,x=mean_div,fill=subclass))+
  geom_boxplot()+
  facet_grid(.~subclass+Chromosome,scales='free')+
  theme_bw(base_size=7)

pdf('divergence_plot.pdf',height=6,width=9)
div_plot
dev.off()


