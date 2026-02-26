<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeamResource\Pages;
use App\Filament\Resources\TeamResource\RelationManagers;
use App\Models\Team;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class TeamResource extends Resource
{
    protected static ?string $model = Team::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';
    protected static ?string $navigationGroup = 'Pronostics';
    protected static ?string $navigationLabel = 'Équipes';
    protected static ?string $modelLabel = 'Équipe';
    protected static ?string $pluralModelLabel = 'Équipes';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('name')
                    ->label('Nom de l\'équipe')
                    ->required()
                    ->maxLength(255),
                
                Forms\Components\TextInput::make('short_name')
                    ->label('Nom court')
                    ->maxLength(10)
                    ->helperText('Acronyme ou nom court (ex: PSG, OM)'),
                
                Forms\Components\Select::make('country')
                    ->label('Pays')
                    ->options([
                        'AFG' => 'Afghanistan',
                        'ZAF' => 'Afrique du Sud',
                        'ALB' => 'Albanie',
                        'DZA' => 'Algérie',
                        'DEU' => 'Allemagne',
                        'AND' => 'Andorre',
                        'AGO' => 'Angola',
                        'ATG' => 'Antigua-et-Barbuda',
                        'SAU' => 'Arabie saoudite',
                        'ARG' => 'Argentine',
                        'ARM' => 'Arménie',
                        'AUS' => 'Australie',
                        'AUT' => 'Autriche',
                        'AZE' => 'Azerbaïdjan',
                        'BHS' => 'Bahamas',
                        'BHR' => 'Bahreïn',
                        'BGD' => 'Bangladesh',
                        'BRB' => 'Barbade',
                        'BLR' => 'Bélarus',
                        'BEL' => 'Belgique',
                        'BLZ' => 'Belize',
                        'BEN' => 'Bénin',
                        'BTN' => 'Bhoutan',
                        'BOL' => 'Bolivie',
                        'BIH' => 'Bosnie-Herzégovine',
                        'BWA' => 'Botswana',
                        'BRA' => 'Brésil',
                        'BRN' => 'Brunéi',
                        'BGR' => 'Bulgarie',
                        'BFA' => 'Burkina Faso',
                        'BDI' => 'Burundi',
                        'KHM' => 'Cambodge',
                        'CMR' => 'Cameroun',
                        'CAN' => 'Canada',
                        'CPV' => 'Cap-Vert',
                        'CAF' => 'Centrafrique',
                        'CHL' => 'Chili',
                        'CHN' => 'Chine',
                        'CYP' => 'Chypre',
                        'COL' => 'Colombie',
                        'COM' => 'Comores',
                        'COG' => 'Congo',
                        'COD' => 'Congo (RDC)',
                        'PRK' => 'Corée du Nord',
                        'KOR' => 'Corée du Sud',
                        'CRI' => 'Costa Rica',
                        'CIV' => 'Côte d\'Ivoire',
                        'HRV' => 'Croatie',
                        'CUB' => 'Cuba',
                        'DNK' => 'Danemark',
                        'DJI' => 'Djibouti',
                        'DOM' => 'Dominique',
                        'EGY' => 'Égypte',
                        'ARE' => 'Émirats arabes unis',
                        'ECU' => 'Équateur',
                        'ERI' => 'Érythrée',
                        'ESP' => 'Espagne',
                        'EST' => 'Estonie',
                        'SWZ' => 'Eswatini',
                        'USA' => 'États-Unis',
                        'ETH' => 'Éthiopie',
                        'FJI' => 'Fidji',
                        'FIN' => 'Finlande',
                        'FRA' => 'France',
                        'GAB' => 'Gabon',
                        'GMB' => 'Gambie',
                        'GEO' => 'Géorgie',
                        'GHA' => 'Ghana',
                        'GRC' => 'Grèce',
                        'GRD' => 'Grenade',
                        'GTM' => 'Guatemala',
                        'GIN' => 'Guinée',
                        'GNB' => 'Guinée-Bissau',
                        'GNQ' => 'Guinée équatoriale',
                        'GUY' => 'Guyana',
                        'HTI' => 'Haïti',
                        'HND' => 'Honduras',
                        'HUN' => 'Hongrie',
                        'IND' => 'Inde',
                        'IDN' => 'Indonésie',
                        'IRQ' => 'Irak',
                        'IRN' => 'Iran',
                        'IRL' => 'Irlande',
                        'ISL' => 'Islande',
                        'ISR' => 'Israël',
                        'ITA' => 'Italie',
                        'JAM' => 'Jamaïque',
                        'JPN' => 'Japon',
                        'JOR' => 'Jordanie',
                        'KAZ' => 'Kazakhstan',
                        'KEN' => 'Kenya',
                        'KGZ' => 'Kirghizistan',
                        'KIR' => 'Kiribati',
                        'KWT' => 'Koweït',
                        'LAO' => 'Laos',
                        'LSO' => 'Lesotho',
                        'LVA' => 'Lettonie',
                        'LBN' => 'Liban',
                        'LBR' => 'Libéria',
                        'LBY' => 'Libye',
                        'LIE' => 'Liechtenstein',
                        'LTU' => 'Lituanie',
                        'LUX' => 'Luxembourg',
                        'MKD' => 'Macédoine du Nord',
                        'MDG' => 'Madagascar',
                        'MYS' => 'Malaisie',
                        'MWI' => 'Malawi',
                        'MDV' => 'Maldives',
                        'MLI' => 'Mali',
                        'MLT' => 'Malte',
                        'MAR' => 'Maroc',
                        'MHL' => 'Marshall',
                        'MUS' => 'Maurice',
                        'MRT' => 'Mauritanie',
                        'MEX' => 'Mexique',
                        'FSM' => 'Micronésie',
                        'MDA' => 'Moldavie',
                        'MCO' => 'Monaco',
                        'MNG' => 'Mongolie',
                        'MNE' => 'Monténégro',
                        'MOZ' => 'Mozambique',
                        'MMR' => 'Myanmar',
                        'NAM' => 'Namibie',
                        'NRU' => 'Nauru',
                        'NPL' => 'Népal',
                        'NIC' => 'Nicaragua',
                        'NER' => 'Niger',
                        'NGA' => 'Nigéria',
                        'NOR' => 'Norvège',
                        'NZL' => 'Nouvelle-Zélande',
                        'OMN' => 'Oman',
                        'UGA' => 'Ouganda',
                        'UZB' => 'Ouzbékistan',
                        'PAK' => 'Pakistan',
                        'PLW' => 'Palaos',
                        'PAN' => 'Panama',
                        'PNG' => 'Papouasie-Nouvelle-Guinée',
                        'PRY' => 'Paraguay',
                        'NLD' => 'Pays-Bas',
                        'PER' => 'Pérou',
                        'PHL' => 'Philippines',
                        'POL' => 'Pologne',
                        'PRT' => 'Portugal',
                        'QAT' => 'Qatar',
                        'DOM' => 'République dominicaine',
                        'CZE' => 'République tchèque',
                        'ROU' => 'Roumanie',
                        'GBR' => 'Royaume-Uni',
                        'RUS' => 'Russie',
                        'RWA' => 'Rwanda',
                        'KNA' => 'Saint-Christophe-et-Niévès',
                        'SMR' => 'Saint-Marin',
                        'VCT' => 'Saint-Vincent-et-les-Grenadines',
                        'LCA' => 'Sainte-Lucie',
                        'SLB' => 'Salomon',
                        'SLV' => 'Salvador',
                        'WSM' => 'Samoa',
                        'STP' => 'Sao Tomé-et-Principe',
                        'SEN' => 'Sénégal',
                        'SRB' => 'Serbie',
                        'SYC' => 'Seychelles',
                        'SLE' => 'Sierra Leone',
                        'SGP' => 'Singapour',
                        'SVK' => 'Slovaquie',
                        'SVN' => 'Slovénie',
                        'SOM' => 'Somalie',
                        'SDN' => 'Soudan',
                        'SSD' => 'Soudan du Sud',
                        'LKA' => 'Sri Lanka',
                        'SWE' => 'Suède',
                        'CHE' => 'Suisse',
                        'SUR' => 'Suriname',
                        'SYR' => 'Syrie',
                        'TJK' => 'Tadjikistan',
                        'TZA' => 'Tanzanie',
                        'TCD' => 'Tchad',
                        'THA' => 'Thaïlande',
                        'TLS' => 'Timor oriental',
                        'TGO' => 'Togo',
                        'TON' => 'Tonga',
                        'TTO' => 'Trinité-et-Tobago',
                        'TUN' => 'Tunisie',
                        'TKM' => 'Turkménistan',
                        'TUR' => 'Turquie',
                        'TUV' => 'Tuvalu',
                        'UKR' => 'Ukraine',
                        'URY' => 'Uruguay',
                        'VUT' => 'Vanuatu',
                        'VAT' => 'Vatican',
                        'VEN' => 'Venezuela',
                        'VNM' => 'Viêt Nam',
                        'YEM' => 'Yémen',
                        'ZMB' => 'Zambie',
                        'ZWE' => 'Zimbabwe',
                    ])
                    ->searchable(),
                
                Forms\Components\FileUpload::make('logo')
                    ->label('Logo')
                    ->image()
                    ->directory('teams/logos')
                    ->disk('public')
                    ->maxSize(2048)
                    ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
                    ->rules([new \App\Rules\SafeFile()]),
                
                Forms\Components\ColorPicker::make('color_primary')
                    ->label('Couleur principale'),
                
                Forms\Components\ColorPicker::make('color_secondary')
                    ->label('Couleur secondaire'),
                
                Forms\Components\TextInput::make('founded_year')
                    ->label('Année de fondation')
                    ->numeric()
                    ->minValue(1800)
                    ->maxValue(date('Y')),
                
                Forms\Components\Textarea::make('description')
                    ->label('Description')
                    ->rows(3),
                
                Forms\Components\Toggle::make('is_active')
                    ->label('Équipe active')
                    ->default(true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('Logo')
                    ->disk('public')
                    ->size(40),
                
                Tables\Columns\TextColumn::make('name')
                    ->label('Nom')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('short_name')
                    ->label('Nom court')
                    ->searchable(),
                
                Tables\Columns\TextColumn::make('country')
                    ->label('Pays')
                    ->badge(),
                
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
                
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('name')
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeams::route('/'),
            'create' => Pages\CreateTeam::route('/create'),
            'edit' => Pages\EditTeam::route('/{record}/edit'),
        ];
    }
}
